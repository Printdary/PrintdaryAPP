#ifndef AKAZEFEATUREMATCHER_H
#define AKAZEFEATUREMATCHER_H
#include "FeatureMatcher.h"
#include <opencv2/features2d.hpp>

class AkazeFeatureMatcher : public FeatureMatcher{
public:
	struct Options {
		Options();
		int descriptor_type;		
		int descriptor_size;
		int descriptor_channels;
		float threshold;
		int nOctaves;
		int nOctaveLayers;
		int diffusivity;
	};
public:
	AkazeFeatureMatcher(Options options= Options());
    virtual void featuresInYaml(const cv::Mat& img, int countOfFeatures, const cv::String& yamlPath) override;
	
private:
    std::vector<int> getMax(const std::vector <cv::KeyPoint> & inputVector, int countOfReturnValue);
    Options m_options;

};
#endif  //AKAZEFEATUREMATCHER_H
