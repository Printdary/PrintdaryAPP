#ifndef CLUSTERING_H
#define CLUSTERING_H
#include "opencv2/highgui.hpp"
#include "opencv2/core.hpp"
#include "opencv2/imgproc.hpp"

#include <iostream>
#include <string>


class Clustering {
	
public:
	virtual ~Clustering() {};
    virtual void divideIntoParts(const cv::String& imYamlPath,int deltaForRadius,int deltaForAngles, int i)=0;
};
#endif //ClUSTERING_H
 
