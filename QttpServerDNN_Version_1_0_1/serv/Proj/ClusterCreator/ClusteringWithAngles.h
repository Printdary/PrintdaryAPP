#define CLUSTERINGWITHANGLES_H
#ifdef CLUSTERINGWITHANGLES_H
 
#include "Clustering.h"
#include <opencv2/flann/flann.hpp>

class ClusteringWithAngles :public Clustering {
	
public :
    ClusteringWithAngles(std::string FolderPath,std::string yamlFolderPath);
    virtual void divideIntoParts(const cv::String& imYamlPath, int deltaForAngles, int deltaForRadius, int id) override;
    void toYaml(const cv::String& imYamlPath);

private :
    void VecClustering(const std::vector<std::vector<float> >& Vec, int delta, std::vector< int > &index);
    cv::String filePath(int clusterIdx, int vecIdx, const cv::String &dir);
	std::vector <float> vecToCos(const std::vector<uchar> &featVector, float &Radius);

private :

    std::vector <std::vector <std::vector < float > > > m_angles;
    std::vector <std::vector<std::vector<uchar > > > m_feat;
    std::vector <std::vector<cv::KeyPoint> > m_kpts;
    std::vector <std::vector<int> > m_imageID;
    std::vector <std::vector<float> > m_Radius;
    std::vector <std::vector <int> > m_kptsAngles;

    std::string ImgFolder;
    std::string ImgYamlFolder;
	int m_deltaForRadius;
	int m_deltaForAngles;
	int m_countOfImg;
    std::vector<std::pair<int, std::string> > m_idImgPathMapping;
};

#endif // CLUSTERINGWITHANGLES_H
