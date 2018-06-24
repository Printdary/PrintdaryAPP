#ifndef SURFFEATUREMATCHER_H
#define SURFFEATUREMATCHER_H
#include "FeatureMatcher.h"
#include <opencv2/features2d.hpp>

class SurfFeatureMatcher : public FeatureMatcher {
public:
	struct Options {
		Options();
		double hessianThreshold;
		int nOctaves;
		int nOctaveLayers;
		bool extended;
		bool upright;
	};
public:
	SurfFeatureMatcher(Options options = Options());
    virtual void featuresInYaml(const cv::Mat& img, int countOfFeatures, const cv::String& yamlPath) override;

private:
	std::vector<int> getMax(const std::vector<cv::KeyPoint>& inputVector, int sizeOfReturnValue);


private:
	Options m_options;
};
#endif  //AKAZEFEATUREMATCHER_H
