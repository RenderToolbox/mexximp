// Expose declared constants to matlab for convenience.

#include <mex.h>

#include "mexximp_constants.h"
#include "mexximp_util.h"

static const char* constant_names[] = {
    "scene",
    "camera",
    "light",
    "material",
    "materialProperty",
    "mesh",
    "face",
    "node",
    "texture",
    "meshPrimitive",
    "lightType",
    "materialPropertyType",
    "textureType",
    "materialPropertyKey",
    "postprocessStep",
};

static const mxArray* constant_values[COUNT(constant_names)];

// populate at at call time instead of load
// because they are destroyed between function calls
static const void populate_values() {
    unsigned i = 0;
    constant_values[i++] = mexximp::create_blank_struct(mexximp::scene_field_names, COUNT(mexximp::scene_field_names));
    constant_values[i++] = mexximp::create_blank_struct(mexximp::camera_field_names, COUNT(mexximp::camera_field_names));
    constant_values[i++] = mexximp::create_blank_struct(mexximp::light_field_names, COUNT(mexximp::light_field_names));
    constant_values[i++] = mexximp::create_blank_struct(mexximp::material_field_names, COUNT(mexximp::material_field_names));
    constant_values[i++] = mexximp::create_blank_struct(mexximp::material_property_field_names, COUNT(mexximp::material_property_field_names));
    constant_values[i++] = mexximp::create_blank_struct(mexximp::mesh_field_names, COUNT(mexximp::mesh_field_names));
    constant_values[i++] = mexximp::create_blank_struct(mexximp::face_field_names, COUNT(mexximp::face_field_names));
    constant_values[i++] = mexximp::create_blank_struct(mexximp::node_field_names, COUNT(mexximp::node_field_names));
    constant_values[i++] = mexximp::create_blank_struct(mexximp::texture_field_names, COUNT(mexximp::texture_field_names));
    constant_values[i++] = mexximp::mesh_primitive_struct(0);
    constant_values[i++] = mexximp::create_string_cell(mexximp::light_type_strings, COUNT(mexximp::light_type_strings));
    constant_values[i++] = mexximp::create_string_cell(mexximp::material_property_type_strings, COUNT(mexximp::material_property_type_strings));
    constant_values[i++] = mexximp::create_string_cell(mexximp::texture_type_strings, COUNT(mexximp::texture_type_strings));
    constant_values[i++] = mexximp::create_string_cell(mexximp::nice_key_strings, COUNT(mexximp::nice_key_strings));
    constant_values[i++] = mexximp::postprocess_step_struct(0);
}

void printUsage() {
    mexPrintf("Get a named constant value declared within mexximp:\n");
    mexPrintf("  value = mexximpConstants(name)\n");
    mexPrintf("The following named constants are available:\n");
    
    unsigned num_values = COUNT(constant_names);
    for (unsigned i=0; i<num_values; i++) {
        mexPrintf("  %s\n", constant_names[i]);
    }
    mexPrintf("\n");
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    if (1 != nrhs || !mxIsChar(prhs[0])) {
        printUsage();
        plhs[0] = mexximp::emptyDouble();
        return;
    }
    
    char* whichConstant = mxArrayToString(prhs[0]);
    int index = mexximp::string_index(constant_names, COUNT(constant_names), whichConstant);
    
    if (0 > index) {
        plhs[0] = mexximp::emptyDouble();
        return;
    }
    
    populate_values();
    plhs[0] = mxDuplicateArray(constant_values[index]);
}
