//@author: mholub
//@help: Update particle velocities and positions
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
};

struct Particle {
	float4 P;
	float4 V;
};

RWStructuredBuffer<Particle> Output : BACKBUFFER;
int Count <string uiname = "Particles Count"; int uimin = 0;> = 10000;

[numthreads(64, 1, 1)]
void CS(uint3 ID : SV_DispatchThreadID) {
	if ((int)ID.x < Count) {
		float4 p = Output[ID.x].P;
		float4 v = Output[ID.x].V;
		
		p += float4(v.x, v.y, 0, 0) * timeScale;
		Output[ID.x].P = p;
	}
}

technique11 Simulation
{
	pass P0
	{
		SetComputeShader ( CompileShader ( cs_5_0, CS() ) );
	}
}



