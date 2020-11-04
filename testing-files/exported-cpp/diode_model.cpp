/* ------------------------------------------------------------
name: "untitled"
Code generated with Faust 2.28.6 (https://faust.grame.fr)
Compilation options: -lang cpp -scal -ftz 0
------------------------------------------------------------ */

#ifndef  __mydsp_H__
#define  __mydsp_H__

#ifndef FAUSTFLOAT
#define FAUSTFLOAT float
#endif 

#include <algorithm>
#include <cmath>


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
	
 public:
	
	void metadata(Meta* m) { 
		m->declare("basics.lib/name", "Faust Basic Element Library");
		m->declare("basics.lib/version", "0.1");
		m->declare("filename", "untitled.dsp");
		m->declare("maths.lib/author", "GRAME");
		m->declare("maths.lib/copyright", "GRAME");
		m->declare("maths.lib/license", "LGPL with exception");
		m->declare("maths.lib/name", "Faust Math Library");
		m->declare("maths.lib/version", "2.3");
		m->declare("name", "untitled");
	}

	virtual int getNumInputs() {
		return 2;
	}
	virtual int getNumOutputs() {
		return 1;
	}
	virtual int getInputRate(int channel) {
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
	}
	
	virtual void instanceResetUserInterface() {
	}
	
	virtual void instanceClear() {
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
		FAUSTFLOAT* input0 = inputs[0];
		FAUSTFLOAT* input1 = inputs[1];
		FAUSTFLOAT* output0 = outputs[0];
		for (int i = 0; (i < count); i = (i + 1)) {
			float fTemp0 = float(input1[i]);
			int iTemp1 = ((fTemp0 > 0.0f) - (fTemp0 < 0.0f));
			float fTemp2 = float(input0[i]);
			float fTemp3 = (fTemp2 * std::exp((0.0039138943f * (fTemp0 * float(iTemp1)))));
			float fTemp4 = (9.86301405e-12f * fTemp3);
			float fTemp5 = std::sqrt((2.0f * ((2.68104514e-11f * fTemp3) + 1.0f)));
			float fTemp6 = ((fTemp4 < 1.0f) ? ((fTemp5 * ((fTemp5 * ((0.152777776f * fTemp5) + -0.333333343f)) + 1.0f)) + -1.0f) : std::log(std::fabs(fTemp4)));
			float fTemp7 = std::exp(fTemp6);
			float fTemp8 = ((fTemp6 * fTemp7) - fTemp4);
			float fTemp9 = (fTemp6 + 1.0f);
			float fTemp10 = (fTemp8 / ((fTemp7 * fTemp9) - (0.5f * ((fTemp8 * (fTemp6 + 2.0f)) / fTemp9))));
			float fTemp11 = (fTemp6 - fTemp10);
			float fTemp12 = std::exp(fTemp11);
			float fTemp13 = ((fTemp11 * fTemp12) - fTemp4);
			float fTemp14 = (fTemp6 + (1.0f - fTemp10));
			float fTemp15 = (fTemp10 + (fTemp13 / ((fTemp12 * fTemp14) - (0.5f * ((fTemp13 * (fTemp6 + (2.0f - fTemp10))) / fTemp14)))));
			float fTemp16 = (fTemp6 - fTemp15);
			float fTemp17 = std::exp(fTemp16);
			float fTemp18 = ((fTemp16 * fTemp17) - fTemp4);
			float fTemp19 = (fTemp6 + (1.0f - fTemp15));
			float fTemp20 = (fTemp15 + (fTemp18 / ((fTemp17 * fTemp19) - (0.5f * ((fTemp18 * (fTemp6 + (2.0f - fTemp15))) / fTemp19)))));
			float fTemp21 = (fTemp6 - fTemp20);
			float fTemp22 = std::exp(fTemp21);
			float fTemp23 = ((fTemp21 * fTemp22) - fTemp4);
			float fTemp24 = (fTemp6 + (1.0f - fTemp20));
			float fTemp25 = (fTemp20 + (fTemp23 / ((fTemp22 * fTemp24) - (0.5f * ((fTemp23 * (fTemp6 + (2.0f - fTemp20))) / fTemp24)))));
			float fTemp26 = (fTemp6 - fTemp25);
			float fTemp27 = std::exp(fTemp26);
			float fTemp28 = ((fTemp26 * fTemp27) - fTemp4);
			float fTemp29 = (fTemp6 + (1.0f - fTemp25));
			float fTemp30 = (fTemp4 + 0.36787945f);
			float fTemp31 = std::sqrt(fTemp30);
			float fTemp32 = ((0.0f - (2.51999999e-09f * fTemp2)) * std::exp((0.0039138943f * (fTemp0 * float((-1 * iTemp1))))));
			float fTemp33 = (0.0039138943f * fTemp32);
			float fTemp34 = std::sqrt((2.0f * ((0.0106390677f * fTemp32) + 1.0f)));
			float fTemp35 = ((fTemp33 < 1.0f) ? ((fTemp34 * ((fTemp34 * ((0.152777776f * fTemp34) + -0.333333343f)) + 1.0f)) + -1.0f) : std::log(std::fabs(fTemp33)));
			float fTemp36 = std::exp(fTemp35);
			float fTemp37 = ((fTemp35 * fTemp36) - fTemp33);
			float fTemp38 = (fTemp35 + 1.0f);
			float fTemp39 = (fTemp37 / ((fTemp36 * fTemp38) - (0.5f * ((fTemp37 * (fTemp35 + 2.0f)) / fTemp38))));
			float fTemp40 = (fTemp35 - fTemp39);
			float fTemp41 = std::exp(fTemp40);
			float fTemp42 = ((fTemp40 * fTemp41) - fTemp33);
			float fTemp43 = (fTemp35 + (1.0f - fTemp39));
			float fTemp44 = (fTemp39 + (fTemp42 / ((fTemp41 * fTemp43) - (0.5f * ((fTemp42 * (fTemp35 + (2.0f - fTemp39))) / fTemp43)))));
			float fTemp45 = (fTemp35 - fTemp44);
			float fTemp46 = std::exp(fTemp45);
			float fTemp47 = ((fTemp45 * fTemp46) - fTemp33);
			float fTemp48 = (fTemp35 + (1.0f - fTemp44));
			float fTemp49 = (fTemp44 + (fTemp47 / ((fTemp46 * fTemp48) - (0.5f * ((fTemp47 * (fTemp35 + (2.0f - fTemp44))) / fTemp48)))));
			float fTemp50 = (fTemp35 - fTemp49);
			float fTemp51 = std::exp(fTemp50);
			float fTemp52 = ((fTemp50 * fTemp51) - fTemp33);
			float fTemp53 = (fTemp35 + (1.0f - fTemp49));
			float fTemp54 = (fTemp49 + (fTemp52 / ((fTemp51 * fTemp53) - (0.5f * ((fTemp52 * (fTemp35 + (2.0f - fTemp49))) / fTemp53)))));
			float fTemp55 = (fTemp35 - fTemp54);
			float fTemp56 = std::exp(fTemp55);
			float fTemp57 = ((fTemp55 * fTemp56) - fTemp33);
			float fTemp58 = (fTemp35 + (1.0f - fTemp54));
			float fTemp59 = (fTemp33 + 0.36787945f);
			float fTemp60 = std::sqrt(fTemp59);
			output0[i] = FAUSTFLOAT((fTemp0 - (255.5f * (float((2 * iTemp1)) * (((fTemp4 < -0.367779434f) ? (((2.33164406f * fTemp31) + (fTemp30 * ((1.93663108f * fTemp31) + -1.81218791f))) + -1.0f) : (fTemp6 - (fTemp25 + (fTemp28 / ((fTemp27 * fTemp29) - (0.5f * ((fTemp28 * (fTemp6 + (2.0f - fTemp25))) / fTemp29))))))) + ((fTemp33 < -0.367779434f) ? (((2.33164406f * fTemp60) + (fTemp59 * ((1.93663108f * fTemp60) + -1.81218791f))) + -1.0f) : (fTemp35 - (fTemp54 + (fTemp57 / ((fTemp56 * fTemp58) - (0.5f * ((fTemp57 * (fTemp35 + (2.0f - fTemp54))) / fTemp58))))))))))));
		}
	}

};

#endif
