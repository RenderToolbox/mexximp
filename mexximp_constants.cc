// Expose declared constants to matlab for convenience.

#include <mex.h>

#include "mexximp_constants.h"
#include "mexximp_util.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    if (1 != nrhs || !mxIsChar(prhs[0])) {
        plhs[0] = mexximp::emptyDouble();
        return;
    }
    
    char* whichConstant = mxArrayToString(prhs[0]);
    if (!whichConstant) {
        plhs[0] = mexximp::emptyDouble();
        return;
    }
    
    if (0 == strcmp("scene", whichConstant)) {
        plhs[0] = mexximp::create_blank_struct(mexximp::scene_field_names, COUNT(mexximp::scene_field_names));
    } else if(0 == strcmp("camera", whichConstant)) {
        plhs[0] = mexximp::create_blank_struct(mexximp::camera_field_names, COUNT(mexximp::camera_field_names));
    } else if(0 == strcmp("light", whichConstant)) {
        plhs[0] = mexximp::create_blank_struct(mexximp::light_field_names, COUNT(mexximp::light_field_names));
    } else if(0 == strcmp("material", whichConstant)) {
        plhs[0] = mexximp::create_blank_struct(mexximp::material_field_names, COUNT(mexximp::material_field_names));
    } else if(0 == strcmp("materialProperty", whichConstant)) {
        plhs[0] = mexximp::create_blank_struct(mexximp::material_property_field_names, COUNT(mexximp::material_property_field_names));
    } else if(0 == strcmp("mesh", whichConstant)) {
        plhs[0] = mexximp::create_blank_struct(mexximp::mesh_field_names, COUNT(mexximp::mesh_field_names));
    } else if(0 == strcmp("face", whichConstant)) {
        plhs[0] = mexximp::create_blank_struct(mexximp::face_field_names, COUNT(mexximp::face_field_names));
    } else if(0 == strcmp("node", whichConstant)) {
        plhs[0] = mexximp::create_blank_struct(mexximp::node_field_names, COUNT(mexximp::node_field_names));
    } else if(0 == strcmp("texture", whichConstant)) {
        plhs[0] = mexximp::create_blank_struct(mexximp::texture_field_names, COUNT(mexximp::texture_field_names));
    } else if(0 == strcmp("meshPrimitive", whichConstant)) {
        plhs[0] = mexximp::mesh_primitive_struct(0);
    } else if(0 == strcmp("lightType", whichConstant)) {
        plhs[0] = mexximp::create_string_cell(mexximp::light_type_strings, COUNT(mexximp::light_type_strings));
    } else if(0 == strcmp("materialPropertyType", whichConstant)) {
        plhs[0] = mexximp::create_string_cell(mexximp::material_property_type_strings, COUNT(mexximp::material_property_type_strings));
    } else if(0 == strcmp("textureType", whichConstant)) {
        plhs[0] = mexximp::create_string_cell(mexximp::texture_type_strings, COUNT(mexximp::texture_type_strings));
    } else if(0 == strcmp("materialPropertyKey", whichConstant)) {
        plhs[0] = mexximp::create_string_cell(mexximp::nice_key_strings, COUNT(mexximp::nice_key_strings));
    } else if(0 == strcmp("postprocessStep", whichConstant)) {
        plhs[0] = mexximp::postprocess_step_struct(0);
    }
}
