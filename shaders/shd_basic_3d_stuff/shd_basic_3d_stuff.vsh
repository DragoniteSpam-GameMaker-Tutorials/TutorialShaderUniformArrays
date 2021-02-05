attribute vec3 in_Position;                  // (x,y,z)
attribute vec3 in_Normal;                    // (x,y,z)     unused in this shader.
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec2 in_TextureCoord;              // (u,v)

#define MAX_LIGHTS 3

uniform vec3 lightPosition[MAX_LIGHTS];
uniform vec4 lightColor;
uniform float lightRange;

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

varying vec3 v_worldPosition;

float eval_light(vec3 world_position, vec3 world_normal, vec3 light_position, float light_radius) {
    vec3 lightDir = world_position - light_position;
    float lightDist = length(lightDir);
    float att = max((light_radius - lightDist) / light_radius, 0.);
    
    lightDir = normalize(-lightDir);
    float NdotL = max(dot(world_normal, lightDir), 0.);
    
    return att * NdotL;
}

void main() {
    vec4 object_space_pos = vec4(in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
    v_worldPosition = (gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos).xyz;
    
    vec4 lightAmbient = vec4(0.25, 0.25, 0.25, 1.);
    
    // Point light stuff
    vec3 worldPosition = (gm_Matrices[MATRIX_WORLD] * vec4(in_Position, 1.)).xyz;
    vec3 worldNormal = normalize(gm_Matrices[MATRIX_WORLD] * vec4(in_Normal, 0.)).xyz;
    
    float light_amount = eval_light(worldPosition, worldNormal, lightPosition[0], lightRange);
    light_amount += eval_light(worldPosition, worldNormal, lightPosition[1], lightRange);
    light_amount += eval_light(worldPosition, worldNormal, lightPosition[2], lightRange);
    
    v_vColour = in_Colour * vec4(min(lightAmbient + lightColor * light_amount, vec4(1.)).rgb, in_Colour.a);
    v_vTexcoord = in_TextureCoord;
}