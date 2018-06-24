#ifndef FEATUREMATCHER_H
#define FEATUREMATCHER_H

#include <opencv2/imgcodecs.hpp>
#include <opencv2/opencv.hpp>
#include <opencv2/core/core.hpp>
#include <string>

namespace cv {
	class Mat;
}

class FeatureMatcher {
public:
	virtual ~FeatureMatcher() {};
    virtual void featuresInYaml(const cv::Mat& img , int countOfFeatures, const cv::String& yamlPath) = 0;
};


#endif //FEATUREMATCHER_H
