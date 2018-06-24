#ifndef FEATUREDETECTIOR_H
#define FEATUREDETECTIOR_H

#include "FeatureMatcher.h"
#include "AkazeFeatureMatcher.h"
#include "ORBFeatureMatcher.h"
#include "SiftFeatureMatcher.h"
#include "SurfFeatureMatcher.h"
#include "Parameters.h"
#include <QThread>

class FeatureDetector{
public:
    FeatureDetector();
    void run (const ParametrsForFeatureDetector &Params,const std::vector<cv::String> & vec);
    void infoAboutThis(ParametrsForFeatureDetector Params);
private:
    FeatureMatcher *detectFeatureMatcherType(const detectorType &type);
    bool createFeatures(const ParametrsForFeatureDetector &Params,const std::vector<cv::String> & vec);

    std::string imageName(std::string Path);
    bool isFormatYaml(std::string path);
private:
    int s=0;
    FeatureMatcher *m_detector;
    std::string m_detectorName;

};


#endif // FEATUREDETECTOR_H
