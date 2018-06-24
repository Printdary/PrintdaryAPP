#include "AkazeFeatureMatcher.h"

#include <opencv2/features2d.hpp>
#include <opencv2/opencv.hpp>

#include <string>



AkazeFeatureMatcher::AkazeFeatureMatcher(Options options):m_options(options)
{

}

std::vector<int> AkazeFeatureMatcher::getMax(const std::vector<cv::KeyPoint>& inputVector, int sizeOfReturnValue)
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


void AkazeFeatureMatcher::featuresInYaml(const cv::Mat &img, int countOfFeatures, const cv::String & yamlPath)
{
	cv::Ptr<cv::AKAZE> akaze = cv::AKAZE::create(m_options.descriptor_type,
		m_options.descriptor_size, m_options.descriptor_channels,
		m_options.threshold, m_options.nOctaves,
		m_options.nOctaveLayers, m_options.diffusivity);

	cv::Mat desc;
	std::vector <cv::KeyPoint>kpts;
    std::vector <std::vector<uchar> > descVector;

	
	akaze->detectAndCompute(img, cv::Mat(), kpts, desc);
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

	


AkazeFeatureMatcher::Options::Options()
	:descriptor_type(cv::AKAZE::DESCRIPTOR_MLDB),
	 descriptor_size(0),  descriptor_channels(3),
	 threshold(0.001f),  nOctaves(4),
	 nOctaveLayers(4), diffusivity(cv::KAZE::DIFF_PM_G2)
{
}
