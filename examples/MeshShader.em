# Copyright (c) Advanced Micro Devices, Inc., or its affiliates.
#
# SPDX-License-Identifier: MIT OR Apache-2.0

# Create a HLSL source called meshshader
SOURCE meshshader
struct VertexAttributes
{
  float4 position : SV_POSITION;
  float3 color : COLOR0;
};

[RootSignature("")]
[numthreads(1, 1, 1)]
[outputtopology("triangle")]
void MS(uint3 DTid : SV_DispatchThreadID, out indices uint3 indices[1], out vertices VertexAttributes vertices[3])
{
  SetMeshOutputCounts(3, 1);

  VertexAttributes v0 = {
    float4(0, -0.75, 0.5, 1),
    float3(1, 0, 0),
  };
  vertices[0] = v0;
  VertexAttributes v1 = {
    float4(-0.75, 0.75, 0.5, 1),
    float3(0, 1, 0),
  };
  vertices[1] = v1;
  VertexAttributes v2 = {
    float4(0.75, 0.75, 0.5, 1),
    float3(0, 0, 1),
  };
  vertices[2] = v2;
  indices[0] = uint3(0, 1, 2);
}

float4 PS(VertexAttributes vertex) : SV_TARGET
{
  return float4(vertex.color, 1);
}
END

# Compile the source with dxc into a binary
OBJECT meshobj meshshader ms_6_5 MS
OBJECT psobj meshshader ps_6_5 PS

# Allocate buffers in GPU memory for input and output
BUFFER inbuf DATA_TYPE float SIZE 64 SERIES_FROM 0 INC_BY .25
BUFFER outbuf DATA_TYPE float SIZE 32 FILL 0

# Texture using window size if there is a window or 64x64 default size
# TODO Create sampler for shader input
TEXTURE img
  FORMAT R8B8G8A8_TYPELESS
  WIDTH 64
  HEIGHT 64
  CLEAR 0 0 0 0
  CONFIG rendertarget
END

# The root signature
# TODO Extract from shader?
ROOT default
END

PIPELINE meshpipe MESH
  MESH_SHADER meshobj
  PIXEL_SHADER psobj
  RENDER_TARGET_FORMATS R8B8G8A8_TYPELESS
  ROOT default
END

VIEW img_target img AS RTV

# Run the pipeline in a 1x1x1 dispatch
DISPATCH meshpipe
  RENDERTARGET img_target
RUN 1 1 1

# Show img in window if there is one
DISPLAY img

# TODO Allow copying to buffer to use EXPECT or use EXPECT directly with a supported FORMAT?

# Check that the shaders worked as expected
#EXPECT outbuf float OFFSET 0 EQ 10.25 11.5 12.75 14
#EXPECT outbuf float OFFSET 64 EQ 30.25 31.5 32.75 34

# Use DUMP to see a buffer's content
#DUMP outbuf float
