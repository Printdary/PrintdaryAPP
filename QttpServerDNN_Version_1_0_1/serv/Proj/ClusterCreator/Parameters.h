#ifndef PARAMETERS_H
#define PARAMETERS_H


#include <iostream>
#include <opencv2/core.hpp>

enum detectorType{
    eAkazeFeatureMatcher,
    eOrbFeatureMatcher,
    eSiftFeatureMatcher,
    eSurfFeatureMatcher,
};

enum clusterCreatorType{
    eClusteringWithAngles,
    eUnknownClusterType
};

struct ParametrsForFeatureDetector{
    cv::String imagesFolder;
    detectorType detectorName;
    int featuresCount;
};

struct ParametrsForClustering{
    clusterCreatorType clusterType;
    cv::String extractorName;
    cv::String imagesFolder;
    int deltaForAngle;
    int deltaForKptsAngle;
    cv::String clusterFolder;

};

#endif // PARAMETERS_H
