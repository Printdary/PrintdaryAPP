#ifndef ORBFEATUREMATCHER_H
#define ORBFEATUREMATCHER_H
#include "FeatureMatcher.h"
#include <opencv2/features2d.hpp>

class ORBFeatureMatcher : public FeatureMatcher {
public:

	struct Options {
		Options();
		int nfeatures;
		int scaleFactor;
		int nlevels;
		float edgeThreshold;
		int firstLevel;
		int WTA_K;
		int scoreType;
		int patchSize;
		int fastThreshold;
	};
public:
	ORBFeatureMatcher(Options options = Options());
    virtual void featuresInYaml(const cv::Mat& img, int countOfFeatures, const cv::String& yamlPath) override;

private:
	std::vector<int> getMax(const std::vector<cv::KeyPoint>& inputVector, int sizeOfReturnValue);
	Options m_options;

};
#endif  //AKAZEFEATUREMATCHER_H
