/// This represents a camera abstraction.
module camera;

import linear;
import std.math;
import std.algorithm;
import std.stdio;
import bindbc.opengl;

/// Camera abstraction.
/// Camera abstraction.
class Camera {
    mat4 mViewMatrix;
    mat4 mProjectionMatrix;

    vec3 mEyePosition;     /// Camera position in world space
    vec3 mUpVector;        /// Up direction
    vec3 mForwardVector;   /// Looking direction
    vec3 mRightVector;     /// Right direction

    // Euler angles for mouse look
    float yaw;
    float pitch;

    // State for first‐mouse handling
    bool firstMouse;
    int lastX;
    int lastY;

    enum vec3 WORLD_UP = vec3(0.0f, 1.0f, 0.0f);

    /// Constructor
    this() {
        mViewMatrix      = MatrixMakeIdentity();
        mProjectionMatrix = MatrixMakePerspective(90.0f.ToRadians,
                                                  480.0f/640.0f,
                                                  0.1f,
                                                  1000.0f);

        // initial camera state
        mEyePosition   = vec3(-4.49337,0,-4.35443);
        mForwardVector = vec3(0.0f, 0.0f,  1.0f);
        mUpVector      = vec3(0.0f, 1.0f,  0.0f);
        mRightVector   = Cross(mForwardVector, mUpVector).Normalize();

        // yaw of –90° so that forward=(0,0,1)
        yaw   = 90.0f;
        pitch =   0.0f;

        firstMouse = true;
        lastX       = 0;
        lastY       = 0;
    }

    /// “LookAt” build (uses our camera axes + translation)
    mat4 LookAt(vec3 eye, vec3 target, vec3 up) {
        // you could also swap in a textbook lookAt implementation here
        mat4 translation = MatrixMakeTranslation(-eye);
        mat4 rotation    = mat4(
            mRightVector.x,  mRightVector.y,  mRightVector.z,  0.0f,
            mUpVector.x,     mUpVector.y,     mUpVector.z,     0.0f,
            mForwardVector.x, mForwardVector.y, mForwardVector.z, 0.0f,
            0.0f,            0.0f,            0.0f,            1.0f
        );

        return rotation * translation;
    }

    /// Update and return the view matrix
    mat4 UpdateViewMatrix() {
        mViewMatrix = LookAt(mEyePosition,
                             mEyePosition + mForwardVector,
                             mUpVector);
        return mViewMatrix;
    }

    /// Mouse‐look: updates yaw/pitch & rebuilds axes
    void MouseLook(int mouseX, int mouseY) {
        // on first call, just initialize lastX/lastY
        if (firstMouse) {
            firstMouse = false;
            lastX = mouseX;
            lastY = mouseY;
        }

        float sensitivity = 1.25f;
        float xoffset     = (lastX - mouseX) * sensitivity;
        float yoffset     = (lastY - mouseY) * 0.05; // invert Y

        lastX = mouseX;
        lastY = mouseY;

        yaw   += xoffset;
        pitch += yoffset;

        // constrain pitch to avoid gimbal flip
        if (pitch >  89.0f) pitch =  89.0f;
        if (pitch < -89.0f) pitch = -89.0f;

        // rebuild forward vector from spherical coords
        vec3 disp;
        disp.x = cos(yaw.ToRadians) * cos(pitch.ToRadians);
        // disp.y = -sin(pitch.ToRadians);
        disp.y = 0.12;
        disp.z = sin(yaw.ToRadians) * cos(pitch.ToRadians);

        mForwardVector = disp.Normalize();

        // rebuild right & up
        mRightVector = Cross(mForwardVector, WORLD_UP).Normalize();
        mUpVector = Cross(mRightVector, mForwardVector).Normalize();

        // commit into the view matrix
        UpdateViewMatrix();
    }

    /// Movement: forward/back/strafe locked to XZ plane
    void MoveForward() {
        vec3 dir = mForwardVector; dir.y = 0;
        dir = dir.Normalize();
        mEyePosition = mEyePosition - dir;
        UpdateViewMatrix();
    }

    void MoveBackward() {
        vec3 dir = mForwardVector; dir.y = 0;
        dir = dir.Normalize();
        mEyePosition = mEyePosition + dir;
        UpdateViewMatrix();
    }

    void MoveLeft() {
        vec3 dir = mRightVector; dir.y = 0;
        dir = dir.Normalize();
        mEyePosition = mEyePosition - dir;
        UpdateViewMatrix();
    }

    void MoveRight() {
        vec3 dir = mRightVector; dir.y = 0;
        dir = dir.Normalize();
        mEyePosition = mEyePosition + dir;
        UpdateViewMatrix();
    }

    /// Vertical moves (free‐fly)
    void MoveUp() {
        mEyePosition.y += 1.0f;
        UpdateViewMatrix();
    }
    void MoveDown() {
        mEyePosition.y = max(0.0f, mEyePosition.y - 1.0f);
        UpdateViewMatrix();
    }
}
