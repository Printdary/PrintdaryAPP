#ifndef SIFTFEATUREMATCHER_H
#define SIFTFEATUREMATCHER_H
#include "FeatureMatcher.h"

class SiftFeatureMatcher : public FeatureMatcher {
public:
	struct Options {
		Options();
		int nfeatures;
		int nOctaveLayers;
		double contrastThreshold; 
		double edgeThreshold;
		double sigma;
	};
public:
	SiftFeatureMatcher(Options options = Options());
    virtual void featuresInYaml(const cv::Mat& img, int countOfFeatures, const cv::String& yamlPath) override;
private:
	std::vector<int> getMax(const std::vector<cv::KeyPoint>& inputVector, int sizeOfReturnValue);
private:
	Options m_options;
};
#endif  //SIFTFEATUREMATCHER_H
