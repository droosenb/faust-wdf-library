/* ------------------------------------------------------------
name: "untitled"
Code generated with Faust 2.28.0 (https://faust.grame.fr)
Compilation options: -lang cpp -scal -ftz 0
------------------------------------------------------------ */

#ifndef  __mydsp_H__
#define  __mydsp_H__

#ifndef FAUSTFLOAT
#define FAUSTFLOAT float
#endif 

#include <algorithm>
#include <cmath>
#include <math.h>


#ifndef FAUSTCLASS 
#define FAUSTCLASS mydsp
#endif

#ifdef __APPLE__ 
#define exp10f __exp10f
#define exp10 __exp10
#endif

class mydsp : public dsp {
	
 private:
	
	int fSampleRate;
	float fConst0;
	float fConst1;
	float fConst2;
	float fConst3;
	float fConst4;
	float fConst5;
	float fConst6;
	int iRec7[2];
	float fRec6[4];
	float fConst7;
	float fConst8;
	float fConst9;
	float fRec0[2];
	int iRec1[2];
	float fConst10;
	float fRec3[2];
	int iRec4[2];
	
 public:
	
	void metadata(Meta* m) { 
		m->declare("filename", "untitled.dsp");
		m->declare("filters.lib/fir:author", "Julius O. Smith III");
		m->declare("filters.lib/fir:copyright", "Copyright (C) 2003-2019 by Julius O. Smith III <jos@ccrma.stanford.edu>");
		m->declare("filters.lib/fir:license", "MIT-style STK-4.3 license");
		m->declare("filters.lib/iir:author", "Julius O. Smith III");
		m->declare("filters.lib/iir:copyright", "Copyright (C) 2003-2019 by Julius O. Smith III <jos@ccrma.stanford.edu>");
		m->declare("filters.lib/iir:license", "MIT-style STK-4.3 license");
		m->declare("filters.lib/lowpass0_highpass1", "MIT-style STK-4.3 license");
		m->declare("filters.lib/name", "Faust Filters Library");
		m->declare("maths.lib/author", "GRAME");
		m->declare("maths.lib/copyright", "GRAME");
		m->declare("maths.lib/license", "LGPL with exception");
		m->declare("maths.lib/name", "Faust Math Library");
		m->declare("maths.lib/version", "2.3");
		m->declare("name", "untitled");
		m->declare("noises.lib/name", "Faust Noise Generator Library");
		m->declare("noises.lib/version", "0.0");
		m->declare("platform.lib/name", "Generic Platform Library");
		m->declare("platform.lib/version", "0.1");
		m->declare("routes.lib/name", "Faust Signal Routing Library");
		m->declare("routes.lib/version", "0.2");
		m->declare("signals.lib/name", "Faust Signal Routing Library");
		m->declare("signals.lib/version", "0.0");
	}

	virtual int getNumInputs() {
		return 0;
	}
	virtual int getNumOutputs() {
		return 4;
	}
	virtual int getInputRate(int channel) {
		int rate;
		switch ((channel)) {
			default: {
				rate = -1;
				break;
			}
		}
		return rate;
	}
	virtual int getOutputRate(int channel) {
		int rate;
		switch ((channel)) {
			case 0: {
				rate = 1;
				break;
			}
			case 1: {
				rate = 1;
				break;
			}
			case 2: {
				rate = 1;
				break;
			}
			case 3: {
				rate = 1;
				break;
			}
			default: {
				rate = -1;
				break;
			}
		}
		return rate;
	}
	
	static void classInit(int sample_rate) {
	}
	
	virtual void instanceConstants(int sample_rate) {
		fSampleRate = sample_rate;
		fConst0 = std::min<float>(192000.0f, std::max<float>(1.0f, float(fSampleRate)));
		fConst1 = (50000000.0f / fConst0);
		fConst2 = (fConst1 + 4700.0f);
		fConst3 = (1.0f / fConst2);
		fConst4 = (0.5f * fConst2);
		fConst5 = (fConst4 + 100.0f);
		fConst6 = (fConst2 / fConst5);
		fConst7 = ((100000000.0f / fConst0) + 9400.0f);
		fConst8 = ((100.0f - fConst4) / fConst7);
		fConst9 = (1.0f / fConst7);
		fConst10 = (1.0f / fConst5);
	}
	
	virtual void instanceResetUserInterface() {
	}
	
	virtual void instanceClear() {
		for (int l0 = 0; (l0 < 2); l0 = (l0 + 1)) {
			iRec7[l0] = 0;
		}
		for (int l1 = 0; (l1 < 4); l1 = (l1 + 1)) {
			fRec6[l1] = 0.0f;
		}
		for (int l2 = 0; (l2 < 2); l2 = (l2 + 1)) {
			fRec0[l2] = 0.0f;
		}
		for (int l3 = 0; (l3 < 2); l3 = (l3 + 1)) {
			iRec1[l3] = 0;
		}
		for (int l4 = 0; (l4 < 2); l4 = (l4 + 1)) {
			fRec3[l4] = 0.0f;
		}
		for (int l5 = 0; (l5 < 2); l5 = (l5 + 1)) {
			iRec4[l5] = 0;
		}
	}
	
	virtual void init(int sample_rate) {
		classInit(sample_rate);
		instanceInit(sample_rate);
	}
	virtual void instanceInit(int sample_rate) {
		instanceConstants(sample_rate);
		instanceResetUserInterface();
		instanceClear();
	}
	
	virtual mydsp* clone() {
		return new mydsp();
	}
	
	virtual int getSampleRate() {
		return fSampleRate;
	}
	
	virtual void buildUserInterface(UI* ui_interface) {
		ui_interface->openVerticalBox("untitled");
		ui_interface->closeBox();
	}
	
	virtual void compute(int count, FAUSTFLOAT** inputs, FAUSTFLOAT** outputs) {
		FAUSTFLOAT* output0 = outputs[0];
		FAUSTFLOAT* output1 = outputs[1];
		FAUSTFLOAT* output2 = outputs[2];
		FAUSTFLOAT* output3 = outputs[3];
		for (int i = 0; (i < count); i = (i + 1)) {
			iRec7[0] = ((1103515245 * iRec7[1]) + 12345);
			fRec6[0] = (((0.522189379f * fRec6[3]) + ((4.65661287e-10f * float(iRec7[0])) + (2.49495602f * fRec6[1]))) - (2.0172658f * fRec6[2]));
			float fTemp0 = float(iRec1[1]);
			float fTemp1 = (0.0f - (fRec0[1] + fTemp0));
			float fTemp2 = float(iRec4[1]);
			float fTemp3 = (0.0f - (fRec3[1] + fTemp2));
			float fTemp4 = ((0.699999988f * (((0.0499220341f * fRec6[0]) + (0.0506126992f * fRec6[2])) - ((0.0959935337f * fRec6[1]) + (0.00440878607f * fRec6[3])))) + (fConst8 * (fTemp1 + fTemp3)));
			float fTemp5 = (fConst2 * fTemp3);
			float fTemp6 = ((fConst6 * fTemp4) + (fConst9 * (fTemp5 + (0.0f - (fConst2 * fTemp1)))));
			float fTemp7 = (4700.0f * fRec0[1]);
			float fTemp8 = (fConst1 * fTemp0);
			fRec0[0] = (fConst3 * (((0.0f - (fConst1 * fTemp6)) + fTemp7) + (0.0f - fTemp8)));
			iRec1[0] = 0;
			float fRec2 = (fConst3 * (fTemp8 + ((0.0f - (4700.0f * fTemp6)) + (0.0f - fTemp7))));
			float fTemp9 = ((fConst2 * ((fConst9 * fTemp1) + (fConst10 * fTemp4))) + (fConst9 * (0.0f - fTemp5)));
			float fTemp10 = (4700.0f * fRec3[1]);
			float fTemp11 = (fConst1 * fTemp2);
			fRec3[0] = (fConst3 * (((0.0f - (fConst1 * fTemp9)) + fTemp10) + (0.0f - fTemp11)));
			iRec4[0] = 0;
			float fRec5 = (fConst3 * (fTemp11 + ((0.0f - (4700.0f * fTemp9)) + (0.0f - fTemp10))));
			output0[i] = FAUSTFLOAT(fRec0[0]);
			output1[i] = FAUSTFLOAT(fRec2);
			output2[i] = FAUSTFLOAT(fRec3[0]);
			output3[i] = FAUSTFLOAT(fRec5);
			iRec7[1] = iRec7[0];
			for (int j0 = 3; (j0 > 0); j0 = (j0 - 1)) {
				fRec6[j0] = fRec6[(j0 - 1)];
			}
			fRec0[1] = fRec0[0];
			iRec1[1] = iRec1[0];
			fRec3[1] = fRec3[0];
			iRec4[1] = iRec4[0];
		}
	}

};

#endif
