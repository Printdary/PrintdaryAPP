#include "ClusteringWithAngles.h"
#include <fstream>
ClusteringWithAngles::ClusteringWithAngles(std::string folderPath,std::string yamlFolderPath )
    :ImgFolder(folderPath),
     ImgYamlFolder(yamlFolderPath)
{
	m_angles.resize(10000);
	m_feat.resize(10000);
	m_kpts.resize(10000);
	m_imageID.resize(10000);
	m_Radius.resize(10000);
	m_kptsAngles.resize(10000);
	m_countOfImg = 0;
	
}

void ClusteringWithAngles::divideIntoParts(const cv::String & imYamlPath, int deltaForAngles, int deltaForRadius, int id)
{
    m_idImgPathMapping.push_back(std::make_pair(id, imYamlPath));
	m_countOfImg++;
	cv::FileStorage fsRead(imYamlPath, cv::FileStorage::READ);

	m_deltaForRadius = deltaForRadius;
	m_deltaForAngles = deltaForAngles;

	std::vector<cv::KeyPoint> kpoints;
    std::vector<std::vector < uchar > > descriptors;
	std::vector<int> imgID;
	std::vector < int > coef;
	fsRead["desc"] >> descriptors;
	fsRead["kpts"] >> kpoints;
	fsRead["coef"] >> coef;

	if (kpoints.size() != 0) {
		int row = descriptors.size(), col = descriptors.at(0).size();

		std::vector <float> R;
		std::vector < int > index;
		//std::vector < int > index;
        std::vector <std::vector <float> > angles;

		for (int i = 0; i < row; ++i) {
			float Radius;
			imgID.push_back(id);
			angles.push_back(vecToCos(descriptors.at(i), Radius));
			R.push_back(Radius);

		}
		for (int i = 0; i < angles.size(); ++i) {
			index.push_back(0);
		}

		VecClustering(angles, m_deltaForAngles, index);

        //std::cout << std::endl << index.size() << std::endl;
		for (int i = 0; i < index.size(); ++i) {

			

            std::vector <std::vector < uchar > > descriptorsCurr;
			std::vector <int > RCurr, imgIDCurr;
			std::vector < cv::KeyPoint> kpointsCurr;

			int pos = coef.at(i) / deltaForRadius;
			
			if (pos > 0) {

				m_angles.at(pos).push_back(angles.at(i));
				m_feat.at(pos).push_back(descriptors.at(i));
				m_imageID.at(pos).push_back(imgID.at(i));
				m_kpts.at(pos).push_back(kpoints.at(i));
				m_Radius.at(pos).push_back(R.at(i));
				m_kptsAngles.at(pos).push_back(coef.at(i));
			}

		}
	}
}

void ClusteringWithAngles::toYaml(const cv::String & imYamlPath)
{
    std::string _path=imYamlPath + "mapping.map";
    std::ofstream outMapping(_path.c_str());
    for(int i = 0; i < m_idImgPathMapping.size(); ++i) {
        outMapping << m_idImgPathMapping[i].first << ":" << m_idImgPathMapping[i].second<<std::endl;
    }
    outMapping.close();
    std::vector < std::vector<int > > index(1000000);
	int featID = 0;
	for (int i = 0; i < m_angles.size(); ++i) {
		for (int j = 0; j < m_angles.at(i).size(); ++j) {
			index.at(i).push_back(0);
		}
		VecClustering(m_angles.at(i), m_deltaForAngles, index.at(i));
	}
	int countOfClusters = 0;
	for (int i = 0; i < m_imageID.size(); ++i) {

		if (m_imageID.at(i).size() != 0) {
			std::vector<int> featIDs;
			for (int j = 0; j < index.at(i).size(); ++j) {

				featIDs.push_back(featID);
				featID++;
			}
			countOfClusters++;
            cv::String fp = filePath(i, 1, imYamlPath);

			cv::FileStorage fsWrite(fp, cv::FileStorage::WRITE);

			fsWrite << "FeatID" << featIDs;
			fsWrite << "index" << index.at(i);
			fsWrite << "Feat" << m_feat.at(i);
			fsWrite << "kpts" << m_kpts.at(i);
			fsWrite << "imageID" << m_imageID.at(i);
			fsWrite << "Radius" << m_Radius.at(i);
			fsWrite << "kptsAngles" << m_kptsAngles.at(i);
		}
	}
	cv::FileStorage fsWrite(imYamlPath + "/info.yaml", cv::FileStorage::WRITE);

	fsWrite << "type" << 0;
	fsWrite << "countOfFeat" << featID;
	fsWrite << "countOfClusters" << countOfClusters;
	fsWrite << "countOfImg" << m_countOfImg;
	fsWrite << "deltaForRadius" << m_deltaForRadius;
	fsWrite << "deltaForAngles" << m_deltaForAngles;
    fsWrite << "imagesPath"<<ImgFolder;
    fsWrite << "imgYamlPath"<<ImgYamlFolder;

}

void ClusteringWithAngles::VecClustering(const std::vector<std::vector<float> >& Vec, int delta, std::vector<int>& index)
{
	for (int i = 0; i < Vec.size(); ++i) {
		int num = 0;
		for (int position = 0; position < 9; ++position) {

			num = 10 * num + int(Vec.at(i).at(position) / delta);


		}
		index.at(i) = num;

	}

}

cv::String ClusteringWithAngles::filePath(int clusterIdx, int del, const cv::String &dir)
{
	int Range = clusterIdx*del;
    std::stringstream ss;
    ss << Range;
    std::string str = ss.str();
    return dir + "/" + str + ".yaml";
}

std::vector<float> ClusteringWithAngles::vecToCos(const std::vector<uchar>& featVector, float & Radius)
{
	float R = 0;
	Radius = 0;
	for (int i = 0; i < featVector.size(); ++i) {
		Radius += featVector.at(i)*featVector.at(i);
	}
	for (int i = 0; i < 9; ++i) {
		R += featVector.at(i)*featVector.at(i);
	}
	R = sqrt(R);
	Radius = sqrt(Radius);

	std::vector <float> Vecf(featVector.size());
	for (int i = 0; i < 9; ++i) {
		Vecf.at(i) = acos(featVector.at(i) / R)*(180 / CV_PI);
	}

	return Vecf;
}
