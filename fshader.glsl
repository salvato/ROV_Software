// Interpolated values from the vertex shaders
in vec4 Position_worldspace;
in vec4 Normal_cameraspace;
in vec4 EyeDirection_cameraspace;
in vec4 LightDirection_cameraspace;

// Values that stay constant for the whole mesh.
uniform vec4 LightPosition_worldspace;
uniform sampler2D qt_Texture0;

varying vec2 qt_TexCoord0;

void
main() {
  // Light emission properties
  // You probably want to put them as uniforms
  vec4  LightColor = vec4(1.0, 1.0, 1.0, 1.0);
  float LightPower = 5000.0*5000.0;

  // Material properties
  vec4 MaterialDiffuseColor  = texture2D(qt_Texture0, qt_TexCoord0.st);
  vec4 MaterialAmbientColor  = vec4(0.2, 0.2, 0.2, 1.0) * MaterialDiffuseColor;
  vec4 MaterialSpecularColor = vec4(0.1, 0.1, 0.1, 1.0);

  // Distance to the light
  float distance = length(LightPosition_worldspace - Position_worldspace);

  // Normal of the computed fragment, in camera space
  vec4 n = normalize(Normal_cameraspace);

  // Direction of the light (from the fragment to the light)
  vec4 l = normalize(LightDirection_cameraspace);

  // Cosine of the angle between the normal and the light direction,
  // clamped above 0
  //  - light is at the vertical of the triangle -> 1
  //  - light is perpendicular to the triangle -> 0
  //  - light is behind the triangle -> 0
  float cosTheta = clamp(dot(n, l), 0, 1);

  // Eye vector (towards the camera)
  vec4 E = normalize(EyeDirection_cameraspace);

  // Direction in which the triangle reflects the light
  vec4 R = reflect(-l ,n);

  // Cosine of the angle between the Eye vector and the Reflect vector,
  // clamped to 0
  //  - Looking into the reflection -> 1
  //  - Looking elsewhere -> < 1
  float cosAlpha = clamp(dot(E, R), 0, 1);

  gl_FragColor =
    // Ambient : simulates indirect lighting
    MaterialAmbientColor +
    // Diffuse : "color" of the object
    MaterialDiffuseColor * LightColor * LightPower * cosTheta / (distance*distance) +
    // Specular : reflective highlight, like a mirror
    MaterialSpecularColor * LightColor * LightPower * pow(cosAlpha,5) / (distance*distance);
}

