//@author: mholub
//@help: Advect particles by texture field
//@tags: positions
//@credits: 

SamplerState linearSampler : IMMUTABLE
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};
 
cbuffer cbPerDraw : register( b0 )
{
	float4x4 tVP : VIEWPROJECTION;		
};

cbuffer cbPerObj : register( b1 )
{
	float4x4 tW : WORLD;
	float power = 1.0;
	float2 mousePos;
};

struct Particle {
	float4 P;
	float4 V;
};


RWStructuredBuffer<Particle> Output : BACKBUFFER;
int Count <string uiname = "Particles Count"; int uimin = 0;> = 10000;

[numthreads(64, 1, 1)]
void CS_Advect(uint3 ID : SV_DispatchThreadID) {
	if ((int)ID.x < Count) {
		float4 p = Output[ID.x].P;
		float4 v = Output[ID.x].V;
		float2 d = p.xy - mousePos;
		if (length(d) < 0.2) {
			v.xy *= 0.99;
			v.xy += float2(-d.y, d.x) * power * 10.0;
		} else if (length(d) < 0.8) {
			v.xy -= 2 * normalize(d) * length(d) * power;
		}
		Output[ID.x].V = v;
	}
}

technique11 Simulation
{
	pass P0
	{
		SetComputeShader ( CompileShader ( cs_5_0, CS_Advect() ) );
	}
}



