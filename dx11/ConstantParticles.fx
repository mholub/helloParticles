//@author: vux
//@help: template for standard shaders
//@tags: template
//@credits: 

struct Particle {
	float4 P;
};

StructuredBuffer<Particle> ps;
float pSize <string uiname="Particle Size"; float uimin = 0;> = 0.01;
Texture2D particleTex <string uiname="Texture";>;

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
	float4 cAmb <bool color=true;String uiname="Color";> = { 1.0f,1.0f,1.0f,1.0f };
};

struct VS_IN
{
	uint vIndex : SV_VertexID;
};

struct vs2gs {
	float4 PosW: POSITION;
};

struct gs2ps {
	float4 PosWVP: SV_POSITION;
	float2 uv: TEXCOORD0;
};

vs2gs VS(VS_IN input)
{
    vs2gs output;	
    output.PosW  = ps[input.vIndex].P;
    return output;
}

[maxvertexcount(4)]
void GS(point vs2gs input[1], inout TriangleStream<gs2ps> Stream)
{
	gs2ps output;
	output.PosWVP = mul(input[0].PosW + float4(pSize/2, pSize/2, 0, 0), mul(tW, tVP));
	output.uv = float2(1, 1);
	Stream.Append(output);
	output.PosWVP = mul(input[0].PosW + float4(pSize/2, -pSize/2, 0, 0), mul(tW, tVP));
	output.uv = float2(1, 0);
	Stream.Append(output);
	output.PosWVP = mul(input[0].PosW + float4(-pSize/2, pSize/2, 0, 0), mul(tW, tVP));
	output.uv = float2(0, 1);
	Stream.Append(output);
	output.PosWVP = mul(input[0].PosW + float4(-pSize/2, -pSize/2, 0, 0), mul(tW, tVP));
	output.uv = float2(0, 0);
	Stream.Append(output);
}

float4 PS(gs2ps In): SV_Target
{
    float4 col = cAmb * particleTex.Sample(linearSampler, In.uv);
    return col;
}

technique10 Constant
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetGeometryShader( CompileShader( gs_4_0, GS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}




