#include "ORBFeatureMatcher.h"

ORBFeatureMatcher::ORBFeatureMatcher(Options options):m_options(options)
{

}

std::vector<int> ORBFeatureMatcher::getMax(const std::vector<cv::KeyPoint>& inputVector, int sizeOfReturnValue)
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



void ORBFeatureMatcher::featuresInYaml(const cv::Mat & img, int countOfFeatures, const cv::String & yamlPath)
{


	std::vector< cv::KeyPoint> keypoints, lastKpts;

    std::vector < std::vector < uchar > > descVector;

	cv::Mat descriptors;

	cv::Ptr <cv::Feature2D> detector = cv::ORB::create(2000, 1.02, 100);
    detector->detectAndCompute(img, cv::noArray(), keypoints, descriptors);

    std::cout << " hasav"<<descriptors.size()<<std::endl;

	std::vector <int> nums; 
	std::vector < int > coef; 
	nums = getMax(keypoints, countOfFeatures); 
	for (int i = 0; i < nums.size(); i++) {
		std::vector<uchar> imRow;
		for (int j = 0; j < descriptors.cols; ++j) {
			imRow.push_back(descriptors.at<uchar>(nums.at(i), j));
		}
		descVector.push_back(imRow);
		imRow.clear();

		int angle= keypoints.at(nums.at(i)).angle / 360 * (1 << 16);
		coef.push_back(angle);
		lastKpts.push_back(keypoints.at(nums.at(i)));

		if (lastKpts.size() == countOfFeatures) {
			break;
		}
	}
    //std::cout << lastKpts.size();
	cv::FileStorage fileStorageWrite(yamlPath, cv::FileStorage::WRITE);
	fileStorageWrite << "coef" << coef;
	fileStorageWrite << "desc" << descVector;
	fileStorageWrite << "kpts" << lastKpts;
}

ORBFeatureMatcher::Options::Options()
	:nfeatures(500), scaleFactor(1.2f), nlevels( 8), edgeThreshold (31),
	firstLevel(0), WTA_K(2),  scoreType (cv::ORB::HARRIS_SCORE),  patchSize ( 31),  fastThreshold ( 20)
{
}
