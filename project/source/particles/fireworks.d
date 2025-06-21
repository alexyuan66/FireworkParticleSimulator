module fireworks;

import bindbc.opengl;
import std.math;
import std.random;
import std.algorithm;
import linear;
import std.stdio;

struct Particle
{
    vec3 pos;
    vec3 speed;
    vec4 color;
    float size;
    float life;
    float initialLife;
    float cameraDist;
    ubyte type; // 1=rocket, 2=sparkle, 3=trail
    size_t parent;
    float flickerPhase;
}

class Launcher
{
    Particle[] particles;
    size_t lastUsed;
    size_t liveCount;
    size_t nextLaunchId = 1;
    float totalTime = 0.0f;

    float[] particlePosSize;
	float[] particleColor;

    this(size_t maxCount)
    {
        // Initialize array sizes given maxCount
        particles.length = maxCount;
        foreach(ref p; particles)
        {
            p.life = -1f;
        }
        particlePosSize.length = particles.length * 4;
		particleColor.length = particles.length * 4;
        lastUsed = 0;
        liveCount = 0;
    }

    size_t findUnused()
    {
        // Find an unused index (dead particle)

        // First go from last used to end
        foreach(i; lastUsed .. particles.length)
        {
            if (particles[i].life <= 0f)
            {
                lastUsed = i;
                return i;
            }
        }

        // Then go from beginning to last used
        foreach (i; 0 .. lastUsed)
        {
            if (particles[i].life <= 0f)
            {
                lastUsed = i;
                return i;
            }
        }

        lastUsed = 0;
        return 0;
    }

    void launchParticle()
    {
        // Add particle to particle array
        size_t idx = findUnused();
        particles[idx].type = 1; // rocket
        particles[idx].life = 2.5f;
        particles[idx].initialLife = 2.5f;
        particles[idx].pos = vec3(uniform(-5, 5), uniform(-8, -5), uniform(-15, -5));
        particles[idx].speed = vec3(uniform(-0.25, 0.25), 20.0f, uniform(-0.25, 0.25));
        vec4 temp = getRandomBrightColor();
        vec3 rgb0 = vec3(temp.x, temp.y, temp.z);
        vec3 hsv0 = rgbToHsv(rgb0);
        particles[idx].color = vec4(hsv0.x, hsv0.y, hsv0.z, 1.0f);
        particles[idx].size = 0.3f;
        particles[idx].parent = nextLaunchId;
        particles[idx].flickerPhase = uniform(0.0f, PI * 2);
        nextLaunchId++;
    }

    void update(float dt, vec3 camPos)
    {
        // Null out arrays to be sent to VBO
        // Pos + Size and Color
        particlePosSize[] = float.nan;
        particleColor[]   = float.nan;
        size_t count = 0;
        totalTime += dt; 
        
        size_t type1_count = 0;
        size_t type2_count = 0;
        size_t type3_count = 0;

        // Iterate through all particles
        foreach (ref p; particles)
        {
            // Find alive ones
            if (p.life > 0f)
            {
                // Apply drag and gravity to get position based on speed
                float drag = 0.6f;
                p.speed = p.speed * exp(-drag * dt);
                p.speed = p.speed + vec3(0, -1, 0) * dt;
                p.pos = p.pos + p.speed * dt;

                // Create new trail particle for launched particle
                if (p.type == 1)
                {
                    if (uniform(0.0f, 1.0f) < 0.5f) {
                        auto ti = findUnused();
                        auto fv = uniform(1.25f, 1.5f);
                        particles[ti] = Particle(
                            p.pos,
                            p.speed / fv,
                            p.color,
                            p.size,
                            0.5f,
                            0.5f,
                            0f,
                            3,
                            p.parent,
                            uniform(0.0f, PI * 2)
                        );
                    }
                }

                // If launched particle is going to die, explode
                if ((p.life - dt) <= 0f && p.type == 1)
                {
                    foreach(ref t; particles)
                    {
                        if (t.parent == p.parent)
                            t.life = -1f;
                    }

                    foreach (_; 0 .. 250)
                    {
                        auto si = findUnused();
                        auto dir = vec3(uniform(-1.0f, 1.0f), uniform(-1.0f, 1.0f), uniform(-1.0f, 1.0f)).Normalize();
                        particles[si] = Particle(p.pos, dir * uniform(2.0f, 5.0f), p.color, p.size * 0.8f, 2.0f, 2.0f, 0f, 2, p.parent, uniform(0.0f, PI * 2));
                    }

                    p.life = -1f;
                    continue;
                }
                
                // If particle still alive, add to arrays to be drawn
                p.life -= dt;
                p.cameraDist = Magnitude(p.pos - camPos);
                float lifeRatio = p.life / p.initialLife;

                // Position + Size array
                size_t b = count * 4;
                particlePosSize[b+0] = p.pos.x;
                particlePosSize[b+1] = p.pos.y;
                particlePosSize[b+2] = p.pos.z;
                particlePosSize[b+3] = p.size * lifeRatio;

                // Color array
                float H = p.color.x;
                float S = p.color.y;
                float V0= p.color.z;
                float V = V0 * lifeRatio;
                vec3 rgb = hsvToRgb(vec3(H,S,V));
                particleColor[b+0] = rgb.x;
                particleColor[b+1] = rgb.y;
                particleColor[b+2] = rgb.z;
                float flicker = 0.75f + 0.25f * sin(totalTime * 30.0f + p.flickerPhase);
                particleColor[b+3] = p.color.w * lifeRatio * flicker;
                
                count++;

                if (p.type == 1) type1_count++;
                if (p.type == 2) type2_count++;
                if (p.type == 3) type3_count++;
            }
        }

        // Sort particles to ensure correct blending
        particles[0 .. count].sort!((a,b) => b.cameraDist < a.cameraDist);
        liveCount = count;
    }

    vec4 getRandomBrightColor()
    {
        float h = uniform(0.0f, 360.0f);
        float s = 1.0f;
        float v = 1.0f;

        // chroma
        float c = v * s;
        float hh = h / 60.0f;
        float x = c * (1 - abs(hh % 2 - 1));
        float m = v - c;

        float r, g, b;
        if (hh < 1)         { r = c; g = x; b = 0; }
        else if (hh < 2)    { r = x; g = c; b = 0; }
        else if (hh < 3)    { r = 0; g = c; b = x; }
        else if (hh < 4)    { r = 0; g = x; b = c; }
        else if (hh < 5)    { r = x; g = 0; b = c; }
        else                { r = c; g = 0; b = x; }

        return vec4(r + m, g + m, b + m, 1.0f);
    }

    vec3 rgbToHsv(vec3 c)
    {
        // Convert from rgb to hsv color format
        float mx = max(max(c.x,c.y),c.z);
        float mn = min(min(c.x,c.y),c.z);
        float d  = mx - mn;
        float h = 0, s = mx > 0 ? d/mx : 0, v = mx;

        if(d > 0) {
            if(mx == c.x) h = ((c.y - c.z)/d) % 6;
            else if(mx == c.y) h = ((c.z - c.x)/d) + 2;
            else               h = ((c.x - c.y)/d) + 4;
            h *= 60;
            if(h < 0) h += 360;
        }
        return vec3(h, s, v);
    }

    vec3 hsvToRgb(vec3 hsv)
    {
        // Convert from hsv to rsb color format
        float h = hsv.x, s = hsv.y, v = hsv.z;
        float c = v*s;
        float x = c*(1 - abs(fmod(h/60,2) - 1));
        float m = v - c;
        vec3 rgb;
        if(h < 60)       rgb = vec3(c, x, 0);
        else if(h < 120) rgb = vec3(x, c, 0);
        else if(h < 180) rgb = vec3(0, c, x);
        else if(h < 240) rgb = vec3(0, x, c);
        else if(h < 300) rgb = vec3(x, 0, c);
        else             rgb = vec3(c, 0, x);
        return rgb + vec3(m);
    }
}