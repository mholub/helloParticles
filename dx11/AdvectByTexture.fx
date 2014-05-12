//@author: mholub
//@help: Advect particles by texture field
//@tags: positions
//@credits: 

SamplerState linearSampler : IMMUTABLE
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Border;
    AddressV = Border;
};
 
cbuffer cbPerDraw : register( b0 )
{
	float4x4 tVP : VIEWPROJECTION;	
	float timeScale = 1.0/60.0;
	
};

cbuffer cbPerObj : register( b1 )
{
	float4x4 tW : WORLD;
	float velocityScale = 1.0;
};

struct Particle {
	float4 P;
	float4 V;
};

Texture2D advectTex <string uiname="Advection Texture";>;
RWStructuredBuffer<Particle> Output : BACKBUFFER;
int Count <string uiname = "Particles Count"; int uimin = 0;> = 10000;

[numthreads(64, 1, 1)]
void CS_Advect(uint3 ID : SV_DispatchThreadID) {
	if ((int)ID.x < Count) {
		float4 p = Output[ID.x].P;
		float4 v = Output[ID.x].V;
		if (p.x > -1 && p.x < 1 && p.y > -1 && p.y < 1) {				
			v = 0.9 * v + 0.1 * (advectTex.SampleLevel(linearSampler, 0.5 * (p.xy + float2(1, 1)), 0) - float4(0.5, 0.5, 0, 0)) * velocityScale;
		}
	}
}

technique11 Simulation
{
	pass P0
	{
		SetComputeShader ( CompileShader ( cs_5_0, CS_Advect() ) );
	}
}



