//@author: mholub
//@help: Emit particles from positions buffer
//@tags: positions
//@credits: 
 
cbuffer cbPerDraw : register( b0 )
{
	float4x4 tVP : VIEWPROJECTION;	
};

cbuffer cbPerObj : register( b1 )
{
	float4x4 tW : WORLD;
};

StructuredBuffer<float2> InitPositions;
StructuredBuffer<float2> InitVelocities;

struct Particle {
	float4 P;
	float4 V;
};

AppendStructuredBuffer<Particle> Output : BACKBUFFER;
int Count <string uiname = "Particles Count"; int uimin = 0;> = 10000;

[numthreads(64, 1, 1)]
void CS_Emit(uint3 ID : SV_DispatchThreadID) {
	if ((int)ID.x < Count) {
		Particle p;
		p.P = float4(InitPositions[ID.x].x, InitPositions[ID.x].y, 0, 1);
		p.V = float4(InitVelocities[ID.x].x, InitVelocities[ID.x].y, 0, 1);
		Output.Append(p);
	}
}

technique11 Simulation
{
	pass P0
	{
		SetComputeShader ( CompileShader ( cs_5_0, CS_Emit() ) );
	}
}



