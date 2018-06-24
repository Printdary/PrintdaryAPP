#include "SurfFeatureMatcher.h"

#include <opencv2/opencv.hpp>
#include <opencv2/xfeatures2d.hpp>

#include <string>

SurfFeatureMatcher::SurfFeatureMatcher(Options options):m_options(options)
{
}

void SurfFeatureMatcher::featuresInYaml(const cv::Mat& img, int countOfFeatures, const cv::String & yamlPath)
{
	cv::Ptr<cv::Feature2D> surf = cv::xfeatures2d::SURF::create();
	cv::Mat desc;
	std::vector <cv::KeyPoint>kpts;
    std::vector <std::vector<uchar> > descVector;


	surf->detectAndCompute(img, cv::Mat(), kpts, desc);
	std::vector < int > coef;
	std::vector < int > nums = getMax(kpts, countOfFeatures);
	std::vector <cv::KeyPoint> lastKpts;


	for (int i = 0; i < nums.size(); i++) {
		std::vector<uchar> imRow;
		for (int j = 0; j < desc.cols; ++j) {
			imRow.push_back(desc.at<uchar>(nums.at(i), j));
		}
		descVector.push_back(imRow);
		imRow.clear();

		int angle = kpts.at(nums.at(i)).angle / 360 * (1 << 16);
		coef.push_back(angle);
		lastKpts.push_back(kpts.at(nums.at(i)));

		if (lastKpts.size() == countOfFeatures) {
			break;
		}
	}
	
	cv::FileStorage fileStorageWrite(yamlPath, cv::FileStorage::WRITE);
	fileStorageWrite << "coef" << coef;
	fileStorageWrite << "desc" << descVector;
	fileStorageWrite << "kpts" << lastKpts;

}
std::vector<int> SurfFeatureMatcher::getMax(const std::vector<cv::KeyPoint>& inputVector, int sizeOfReturnValue)
{
	std::vector <int> maxs(sizeOfReturnValue);
	std::vector <int> outVec(sizeOfReturnValue);
	for (int i = 0; i < sizeOfReturnValue; ++i) {
		maxs.at(i) = -1;
	}
	for (int i = 0; i < inputVector.size(); ++i) {

		if (inputVector.at(i).response > maxs.at(sizeOfReturnValue - 1)) {
			int posForIt = 0;
			while (maxs.at(posForIt) > inputVector.at(i).response && posForIt < maxs.size()) {
				posForIt++;
			}

			std::vector < int > ::iterator it;
			it = maxs.begin() + posForIt;
			maxs.insert(it, inputVector.at(i).response);
			it = outVec.begin() + posForIt;
			outVec.insert(it, i);

			if (maxs.size() > sizeOfReturnValue) {
				maxs.pop_back();
				outVec.pop_back();

			}
		}
	}
	return outVec;
}
SurfFeatureMatcher::Options::Options()
	:hessianThreshold(100),
	nOctaves(4), nOctaveLayers(3),
	extended(false), upright(false)
{
}
