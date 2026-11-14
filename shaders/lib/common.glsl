#ifndef LIB_COMMON
#define LIB_COMMON

// mat3(mat4) is not available in GLSL 1.20, so build it manually
mat3 toMat3(mat4 m) {
    return mat3(m[0].xyz, m[1].xyz, m[2].xyz);
}

#endif
