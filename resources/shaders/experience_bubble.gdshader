shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_opaque;



uniform sampler2D albedo_texture : source_color;
uniform sampler2D emission_texture;

uniform vec4 albedo_color : source_color = vec4(1.0);
uniform vec4 emission_color : source_color = vec4(1.0);
uniform float emission_strength : hint_range(0.0, 10.0) = 2.0;

void vertex() {
    // Position monde du sommet
    vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

    // Position caméra depuis la matrice inverse de vue
    vec3 camera_pos = (INV_VIEW_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;

    // Direction caméra → objet
    vec3 to_camera = normalize(camera_pos - world_pos);

    // On bloque l'axe Y (billboard vertical)
    to_camera.y = 0.0;
    to_camera = normalize(to_camera);

    // Axes
    vec3 up = vec3(0.0, 1.0, 0.0);
    vec3 right = normalize(cross(up, to_camera));
    vec3 forward = cross(right, up);

    // Matrice billboard
    mat3 billboard = mat3(right, up, forward);

    // Application
    VERTEX = billboard * VERTEX;
}


void fragment() {
    vec4 albedo_tex = texture(albedo_texture, UV);
    ALBEDO = albedo_tex.rgb * albedo_color.rgb;
    ALPHA = albedo_tex.a * albedo_color.a;

    vec4 emission_tex = texture(emission_texture, UV);
    EMISSION = emission_tex.rgb * emission_color.rgb * emission_strength;
}
