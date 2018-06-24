#include "SiftFeatureMatcher.h"

#include <opencv2/opencv.hpp>
#include <opencv2/xfeatures2d.hpp>
#include <string>
SiftFeatureMatcher::SiftFeatureMatcher(Options options):m_options(options)
{
}

void SiftFeatureMatcher::featuresInYaml(const cv::Mat& img, int countOfFeatures, const cv::String & yamlPath)
{

    cv::Ptr<cv::Feature2D> sift = cv::xfeatures2d::SIFT::create(m_options.nfeatures,m_options.nOctaveLayers,m_options.contrastThreshold,m_options.edgeThreshold,m_options.sigma);
	cv::Mat desc;
	std::vector <cv::KeyPoint>kpts;
    std::vector <std::vector<uchar> > descVector;


	sift->detectAndCompute(img, cv::Mat(), kpts, desc);
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



	/*cv::Mat imPart;
	std::vector<cv::KeyPoint> kpts1;

	std::vector <cv::KeyPoint>kpts;
	std::vector <std::vector<uchar>>descs;
	std::vector <std::vector<uchar>> descVector;
	cv::Ptr<cv::Feature2D>  sift = cv::xfeatures2d::SIFT::create(countOfFeatures, m_options.nOctaveLayers,
		m_options.contrastThreshold, m_options.edgeThreshold, m_options.sigma);
	int count = 10;
	for (int i = 0; i < count; ++i) {
		for (int j = 0; j < count; j++) {

			imPart = img(cv::Rect(j * img.cols / count, i * img.rows / count, img.cols / count, img.rows / count));

			cv::Mat desc1;
			sift->detect(imPart, kpts1);
			sift->compute(imPart, kpts1, desc1);
			for (int i = 0; i < desc1.rows; i++) {
				std::vector<uchar> imRow;
				for (int j = 0; j < desc1.cols; ++j) {
					imRow.push_back(desc1.at<uchar>(i, j));
				}
				descVector.push_back(imRow);
				imRow.clear();
			}

			if (kpts1.size() != 0) {
				int size = kpts1.size() < (countOfFeatures / 100) ? kpts1.size() : (countOfFeatures / 100);
				for (int i = 0; i < size; ++i) {
					descs.push_back(descVector.at(i));
					kpts.push_back(kpts1.at(i));
				}
			}

			kpts1.clear();
			descVector.clear();
		}
	}
	cv::FileStorage fileStorageWrite(yamlPath, cv::FileStorage::WRITE);
	fileStorageWrite << "desc" << descs;
	fileStorageWrite << "kpts" << kpts;
*/
}

std::vector<int> SiftFeatureMatcher::getMax(const std::vector<cv::KeyPoint>& inputVector, int sizeOfReturnValue)
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

SiftFeatureMatcher::Options::Options()
	:nfeatures(0),nOctaveLayers (3),
	contrastThreshold(0.04) ,edgeThreshold(10),
	sigma (1.6)
{
}
