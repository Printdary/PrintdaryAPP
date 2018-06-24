#ifndef COMPARE_H
#define COMPARE_H
#include <QObject>

#include <iostream>
#include "InfoProvider.h"

#include <opencv2/imgcodecs.hpp>
#include <opencv2/opencv.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/features2d.hpp>

class Compare{
public:
	Compare(InfoProvider prov);
	void getSimillar(const std::string & path);
private:
	std::string getSimillarImg(const std::vector<std::string> & vec);
	std::string getSimillarWithNear(const std::vector<std::string> & vec); 
	template <class T>
	T EuclideanDistance(const std::vector<T> &v1, const std::vector <T> &v2); 
	std::vector<float> readFeatureFromFile(const std::string & path);
private:
	InfoProvider m_impl;
	std::vector <std::vector <uchar>> m_desc;
	std::vector <cv::KeyPoint> m_kpts;
	cv::Mat m_generalImg;
};
#endif 
