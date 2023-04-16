// Enter Faust code here

import("stdfaust.lib");
//import("signals.lib");
//import("compressors.lib");
//import("delays.lib");
//import("basics.lib");
//import("maths.lib");
//import("filters.lib");


//p1(in1,in2,in3,in4) = in1,in2,in3,in4;
//p2(in1,in2,in3,in4) = in2,in1,in4,in3;
//p3(in1,in2,in3,in4) = in2,in3,in1,in4;
//p4(in1,in2,in3,in4) = in2,in3,in4,in1;
//p5(in1,in2,in3,in4) = in1,in2,in3,in4;

fbsize = nentry("feedbacksize", 0, 0, 3 , 0.1);
outmix = nentry("outmix", 0, 0, 2 , 0.1);
//fbamp = nentry("aaafbamp", 0, 0, 1 , 0.00001);

ratio = nentry("ratio", 10, 1, 100 , 0.1);
thresh = nentry("thresh", -6, -90, 0 , 0.1);
att = nentry("att", 0.01, 0, 100 , 0.1);
rel = nentry("rel", 0.1, 0, 100 , 0.1);

//dcf = nentry("dcf", 1, 0.1, 100 , 0.1);

hq1 = nentry("hq1", 1, 0.1, 100 , 0.1):r_min;
hq2 = nentry("hq2", 1, 0.1, 100 , 0.1):r_min;
hq3 = nentry("hq3", 1, 0.1, 100 , 0.1):r_min;

lq1 = nentry("lq1", 1, 0.1, 100 , 0.1):r_min;
lq2 = nentry("lq2", 1, 0.1, 100 , 0.1):r_min;
lq3 = nentry("lq3", 1, 0.1, 100 , 0.1):r_min;


//dmod1 = nentry("dmod1", 0, 0, 1 , 0.1);
//dmod2 = nentry("dmod2", 0, 0, 1 , 0.1);
//dmod3 = nentry("dmod3", 0, 0, 1 , 0.1);
//dmod4 = nentry("dmod4", 0, 0, 1 , 0.1);

//fc1 = nentry("fc1",2000,20,20000,0.1);
//fc2 = nentry("fc2",2000,20,20000,0.1);
//fc3 = nentry("fc3",2000,20,20000,0.1);
//fc4 = nentry("fc4",2000,20,20000,0.1);

//q1 = nentry("rq1",0.5,0,1,0.1);
//q2 = nentry("rq2",0.5,0,1,0.1);
//q3 = nentry("rq3",0.5,0,1,0.1);
//q4 = nentry("rq4",0.5,0,1,0.1);

//1 2 3 4		//0
//2 1 4 3		//1
//2 3 1 4		//2
//2 3 4 1		//3
//1 2 3 4		//4

//1 2 3 		//0
//2 1 1 		//1
//2 3 1 		//2
//1 2 3 		//3

selectPerm(in1,in2,in3) =
	(in1,in2				:		it.interpolate_linear(min(fbsize,1)),
		in2						:		it.interpolate_linear(max(min(fbsize-1,1),0)),
		in1						:		it.interpolate_linear(max(min(fbsize-2,1),0))),
	(in2,in1				:		it.interpolate_linear(min(fbsize,1)),
		in3						:		it.interpolate_linear(max(min(fbsize-1,1),0)),
		in2						:		it.interpolate_linear(max(min(fbsize-2,1),0))),
	(in3,in1				:		it.interpolate_linear(min(fbsize,1)),
		in1						:		it.interpolate_linear(max(min(fbsize-1,1),0)),
		in3						:		it.interpolate_linear(max(min(fbsize-2,1),0)));

//selectMix(in1,in2,in3,in4) =
//		(in1,(in1+in2)*(2/3)		:		it.interpolate_linear(min(outmix,1)),
//		(in1+in2+in3)*(3/6)			:		it.interpolate_linear(max(min(outmix-1,1),0)),
//		(in1+in2+in3+in4)*(4/9)	:		it.interpolate_linear(max(min(outmix-2,1),0)));

//selectMix(in1,in2,in3) =
//		(in1,(in1+in2)*(2/3)		:		it.interpolate_linear(max(min(outmix,1),0)),
//		(in1+in2+in3)*(3/6)			:		it.interpolate_linear(max(min(outmix-1,1),0)));

selectMix(in1,in2,in3) =
		(in1,(in1+in2)*(2/3)		:		it.interpolate_linear(max(min(outmix,1),0)),
		(in1+in2+in3)*(3/6)			:		it.interpolate_linear(max(min(outmix-1,1),0)));


//select4(in1,in2,in3,in4) = in2,in3,in4,in1;

fbamp3(fbamp) =  _*fbamp,_*fbamp,_*fbamp;

//comp3(ratio,thresh,att,rel) =
//	(compressor_mono(ratio,thresh,att,rel)),
//	(compressor_mono(ratio,thresh,att,rel)),
//	(compressor_mono(ratio,thresh,att,rel));


mycomp(ratio,thresh,att,rel) = _<:_*comp_gain(_):_ with{
	linthresh= ba.db2linear(thresh);
	//linthresh= thresh;
	amplitude(sig) = sig:abs:si.lag_ud(att, rel);
	comp_gain(sig) = ba.if(amplitude(sig)>linthresh,pow(amplitude(sig) / linthresh, (1/ratio) - 1.0),1);
};

comp3(ratio,thresh,att,rel) =
	(mycomp(ratio,thresh,att,rel)),
	(mycomp(ratio,thresh,att,rel)),
	(mycomp(ratio,thresh,att,rel));

//del3(dmod1,dmod2,dmod3) =
//	fdelay4(ma.SR,max(dmod1*ma.SR,3.5)),
//	fdelay4(ma.SR,max(dmod2*ma.SR,3.5)),
//	fdelay4(ma.SR,max(dmod3*ma.SR,3.5));

del3(dmod1,dmod2,dmod3) =
	de.fdelay2(ma.SR,max(dmod1*ma.SR,4)),
	de.fdelay2(ma.SR,max(dmod2*ma.SR,4)),
	de.fdelay2(ma.SR,max(dmod3*ma.SR,4));

//bp3(fc1, fc2, fc3, q1, q2, q3) = fi.resonbp(fc1,q1: si.bsmooth,1),fi.resonbp(fc2,q2:si.bsmooth,1),fi.resonbp(fc3,q3:si.bsmooth,1);

hp3(fc1, fc2, fc3,  q1, q2, q3) = fi.resonhp(fc1,q1:si.bsmooth,1),fi.resonhp(fc2,q2:si.bsmooth,1),fi.resonhp(fc3,q3:si.bsmooth,1);

dc3(dcf) = fi.dcblockerat(dcf),fi.dcblockerat(dcf),fi.dcblockerat(dcf);


lp3(fc1, fc2, fc3, q1, q2, q3) = fi.resonlp(fc1,q1,1),fi.resonlp(fc2,q2,1),fi.resonlp(fc3,q3,1);

ls3(f,b) = fi.low_shelf(b,f),fi.low_shelf(b,f),fi.low_shelf(b,f);
hs3(f,b) = fi.high_shelf(b,f),fi.high_shelf(b,f),fi.high_shelf(b,f);

//add3(fb1,fb2,fb3,in1,in2,in3) = fb1+in1,fb2+in2,fb3+in3;

add6(fb1,fb2,fb3,in1,in2,in3) = fb1+in1,fb2+in2,fb3+in3,fb1,fb2,fb3;

clip3 = clip,clip,clip with{
	// clip = min(10) : max(-10);
	clip = _ / 2 : ma.tanh : _ * 2;
};

f_clip(q) = min(min(24000*q,21999)):max(6);
//f_clip = min(20000):max(20);
//f_clip = _;

r_min = max(0.1):si.lag_ud(0.05, 0.05);

process(
//in1,in2,in3,att
in1, in2, in3,
dmod1, dmod2, dmod3,
hfc1, hfc2, hfc3,
//hq1, hq2, hq3,
lfc1, lfc2, lfc3,
//lq1, lq2, lq3,
lf,lb,
hf,hb,
fbamp
//ratio, thresh, att, rel
) =
in1,in2,in3 :
(add6)  ~ (
 fbamp3(fbamp) :
 comp3(ratio,thresh,att,rel) :
 clip3 :
 del3(dmod1,dmod2,dmod3) :
 hp3(hfc1:f_clip(hq1), hfc2:f_clip(hq2), hfc3:f_clip(hq3), hq1, hq2, hq3) :
 lp3(lfc1:f_clip(lq1), lfc2:f_clip(lq2), lfc3:f_clip(lq3), lq1, lq2, lq3) :
 ls3(lf:f_clip(1),lb) :
 hs3(hf:f_clip(1),hb) :
// dc3(10) :
 selectPerm
): !,!,!,selectMix;
//): !,!,!,_+(outmix*0.0000000001),!,!;
