#ifndef QTTPTESTUTILS_H
#define QTTPTESTUTILS_H

#include <QTest>
#include <qttpserver>

namespace qttp
{
namespace test
{

class TestUtils
{
  public:

    static int MAX_TEST_WAIT_MS;
    QObject* qparent;

    HttpServer* setUp(QObject* parent)
    {
      qparent = parent;
      return HttpServer::getInstance();
    }

    void tearDown()
    {
      HttpServer* httpSvr = HttpServer::getInstance();
      QVERIFY(httpSvr->isInitialized());
      httpSvr->stop();
    }

    void waitUntil(bool& done, int maxTime)
    {
      QTime time;
      time.start();
      while(!done)
      {
        QTest::qWait(300);
        if(time.elapsed() > maxTime)
        {
          break;
        }
      }
    }

    void verifyJson(QByteArray& result, const QByteArray& expectedResp)
    {
      // TODO: FIXME: This section with jsonResult is a work around due to
      // suspicious auto-formatting on windows.  Should follow up and check
      // to make sure httpserver.cpp is sending out compact json.
      QJsonDocument resultDoc = QJsonDocument::fromJson(result);
      QByteArray jsonResult = resultDoc.toJson(QJsonDocument::Compact);

      QJsonDocument doc = QJsonDocument::fromJson(expectedResp);
      QByteArray expected = doc.toJson(QJsonDocument::Compact);
      QCOMPARE(jsonResult, expected);
    }

    void requestGet(QString endpoint)
    {
      QByteArray ignore;
      requestGet(endpoint, ignore);
    }

    void requestGet(QString endpoint, QByteArray& result)
    {
      bool done = false;
      auto callback = [&result, &done](QNetworkReply* reply) {
                        result = reply->readAll();
                        done = true;
                      };
      QNetworkAccessManager* netMgr = new QNetworkAccessManager(qparent);
      QObject::connect(netMgr, &QNetworkAccessManager::finished, callback);
      QUrl url = endpoint;
      QNetworkReply* reply = netMgr->get(QNetworkRequest(url));
      QVERIFY(result.isEmpty());
      waitUntil(done, MAX_TEST_WAIT_MS);
      Q_UNUSED(reply);
    }

    void requestValidGet(QString endpoint, QByteArray& result)
    {
      bool done = false;
      auto callback = [&result, &done](QNetworkReply* reply) {
                        result = reply->readAll();
                        done = true;
                      };
      QNetworkAccessManager* netMgr = new QNetworkAccessManager(qparent);
      QObject::connect(netMgr, &QNetworkAccessManager::finished, callback);
      QUrl url = endpoint;
      QNetworkReply* reply = netMgr->get(QNetworkRequest(url));
      QVERIFY(result.isEmpty());
      waitUntil(done, MAX_TEST_WAIT_MS);
      QCOMPARE(reply->error(), QNetworkReply::NoError);
    }

    void verifyGet(QString endpoint, QNetworkReply::NetworkError error = QNetworkReply::NoError)
    {
      bool done = false;
      auto callback = [&done](QNetworkReply* reply) {
                        done = true;
                        Q_UNUSED(reply);
                      };
      QNetworkAccessManager* netMgr = new QNetworkAccessManager(qparent);
      QObject::connect(netMgr, &QNetworkAccessManager::finished, callback);
      QUrl url = endpoint;
      QNetworkReply* reply = netMgr->get(QNetworkRequest(url));
      waitUntil(done, MAX_TEST_WAIT_MS);
      QCOMPARE(reply->error(), error);
    }

    void verifyErrorGet(QString endpoint)
    {
      bool done = false;
      auto callback = [&done](QNetworkReply* reply) {
                        done = true;
                        Q_UNUSED(reply);
                      };
      QNetworkAccessManager* netMgr = new QNetworkAccessManager(qparent);
      QObject::connect(netMgr, &QNetworkAccessManager::finished, callback);
      QUrl url = endpoint;
      QNetworkReply* reply = netMgr->get(QNetworkRequest(url));
      waitUntil(done, MAX_TEST_WAIT_MS);
      QVERIFY(reply->error() != QNetworkReply::NoError);
    }

    void verifyGetJson(QString endpoint, const QByteArray& expected)
    {
      QByteArray result;
      TestUtils::requestValidGet(endpoint, result);
      TestUtils::verifyJson(result, expected);
    }

    void requestPost(QString endpoint)
    {
      QByteArray ignore;
      requestPost(endpoint, ignore);
    }

    void requestPost(QString endpoint,
                     QByteArray& result,
                     QByteArray postBody = QByteArray(),
                     QString contentType = "text/plain")
    {
      bool done = false;
      auto callback = [&result, &done](QNetworkReply* reply) {
                        result = reply->readAll();
                        done = true;
                      };
      QNetworkAccessManager* netMgr = new QNetworkAccessManager(qparent);
      QObject::connect(netMgr, &QNetworkAccessManager::finished, callback);
      QUrl url = endpoint;
      QNetworkRequest networkRequest(url);
      networkRequest.setHeader(QNetworkRequest::ContentTypeHeader, contentType);
      QNetworkReply* reply = netMgr->post(networkRequest, postBody);
      QVERIFY(result.isEmpty());
      waitUntil(done, MAX_TEST_WAIT_MS);
      Q_UNUSED(reply);
    }

    void requestValidPost(QString endpoint,
                          QByteArray& result,
                          QByteArray postBody = QByteArray(),
                          QString contentType = "text/plain")
    {
      bool done = false;
      auto callback = [&result, &done](QNetworkReply* reply) {
                        result = reply->readAll();
                        done = true;
                      };
      QNetworkAccessManager* netMgr = new QNetworkAccessManager(qparent);
      QObject::connect(netMgr, &QNetworkAccessManager::finished, callback);
      QUrl url = endpoint;
      QNetworkRequest networkRequest(url);
      networkRequest.setHeader(QNetworkRequest::ContentTypeHeader, contentType);
      QNetworkReply* reply = netMgr->post(networkRequest, postBody);
      QVERIFY(result.isEmpty());
      waitUntil(done, MAX_TEST_WAIT_MS);
      QCOMPARE(reply->error(), QNetworkReply::NoError);
    }

    void verifyPost(QString endpoint,
                    QNetworkReply::NetworkError error = QNetworkReply::NoError,
                    QByteArray postBody = QByteArray(),
                    QString contentType = "text/plain")
    {
      bool done = false;
      auto callback = [ &done](QNetworkReply* reply) {
                        done = true;
                        Q_UNUSED(reply);
                      };
      QNetworkAccessManager* netMgr = new QNetworkAccessManager(qparent);
      QObject::connect(netMgr, &QNetworkAccessManager::finished, callback);
      QUrl url = endpoint;
      QNetworkRequest networkRequest(url);
      networkRequest.setHeader(QNetworkRequest::ContentTypeHeader, contentType);
      QNetworkReply* reply = netMgr->post(networkRequest, postBody);
      waitUntil(done, MAX_TEST_WAIT_MS);
      QCOMPARE(reply->error(), error);
    }

    void verifyErrorPost(QString endpoint,
                         QByteArray postBody = QByteArray(),
                         QString contentType = "text/plain")
    {
      bool done = false;
      auto callback = [ &done](QNetworkReply* reply) {
                        done = true;
                        Q_UNUSED(reply);
                      };
      QNetworkAccessManager* netMgr = new QNetworkAccessManager(qparent);
      QObject::connect(netMgr, &QNetworkAccessManager::finished, callback);
      QUrl url = endpoint;
      QNetworkRequest networkRequest(url);
      networkRequest.setHeader(QNetworkRequest::ContentTypeHeader, contentType);
      QNetworkReply* reply = netMgr->post(networkRequest, postBody);
      waitUntil(done, MAX_TEST_WAIT_MS);
      QVERIFY(reply->error() != QNetworkReply::NoError);
    }

    void verifyPostJson(QString endpoint, const QByteArray& expected)
    {
      QByteArray result;
      TestUtils::requestValidPost(endpoint, result);
      TestUtils::verifyJson(result, expected);
    }

    void requestPut(QString endpoint)
    {
      QByteArray ignore;
      requestPut(endpoint, ignore);
    }

    void requestPut(QString endpoint,
                    QByteArray& result,
                    QByteArray putBody = QByteArray(),
                    QString contentType = "text/plain")
    {
      bool done = false;
      auto callback = [&result, &done](QNetworkReply* reply) {
                        result = reply->readAll();
                        done = true;
                      };
      QNetworkAccessManager* netMgr = new QNetworkAccessManager(qparent);
      QObject::connect(netMgr, &QNetworkAccessManager::finished, callback);
      QUrl url = endpoint;
      QNetworkRequest networkRequest(url);
      networkRequest.setHeader(QNetworkRequest::ContentTypeHeader, contentType);
      QNetworkReply* reply = netMgr->put(networkRequest, putBody);
      QVERIFY(result.isEmpty());
      waitUntil(done, MAX_TEST_WAIT_MS);
      Q_UNUSED(reply);
    }

    void requestValidPut(QString endpoint,
                         QByteArray& result,
                         QByteArray putBody = QByteArray(),
                         QString contentType = "text/plain")
    {
      bool done = false;
      auto callback = [&result, &done](QNetworkReply* reply) {
                        result = reply->readAll();
                        done = true;
                      };
      QNetworkAccessManager* netMgr = new QNetworkAccessManager(qparent);
      QObject::connect(netMgr, &QNetworkAccessManager::finished, callback);
      QUrl url = endpoint;
      QNetworkRequest networkRequest(url);
      networkRequest.setHeader(QNetworkRequest::ContentTypeHeader, contentType);
      QNetworkReply* reply = netMgr->put(networkRequest, putBody);
      QVERIFY(result.isEmpty());
      waitUntil(done, MAX_TEST_WAIT_MS);
      QCOMPARE(reply->error(), QNetworkReply::NoError);
    }

    void verifyPut(QString endpoint,
                   QNetworkReply::NetworkError error = QNetworkReply::NoError,
                   QByteArray putBody = QByteArray(),
                   QString contentType = "text/plain")
    {
      bool done = false;
      auto callback = [ &done](QNetworkReply* reply) {
                        done = true;
                        Q_UNUSED(reply);
                      };
      QNetworkAccessManager* netMgr = new QNetworkAccessManager(qparent);
      QObject::connect(netMgr, &QNetworkAccessManager::finished, callback);
      QUrl url = endpoint;
      QNetworkRequest networkRequest(url);
      networkRequest.setHeader(QNetworkRequest::ContentTypeHeader, contentType);
      QNetworkReply* reply = netMgr->put(networkRequest, putBody);
      waitUntil(done, MAX_TEST_WAIT_MS);
      QCOMPARE(reply->error(), error);
    }

    void verifyErrorPut(QString endpoint,
                        QByteArray putBody = QByteArray(),
                        QString contentType = "text/plain")
    {
      bool done = false;
      auto callback = [ &done](QNetworkReply* reply) {
                        done = true;
                        Q_UNUSED(reply);
                      };
      QNetworkAccessManager* netMgr = new QNetworkAccessManager(qparent);
      QObject::connect(netMgr, &QNetworkAccessManager::finished, callback);
      QUrl url = endpoint;
      QNetworkRequest networkRequest(url);
      networkRequest.setHeader(QNetworkRequest::ContentTypeHeader, contentType);
      QNetworkReply* reply = netMgr->put(networkRequest, putBody);
      waitUntil(done, MAX_TEST_WAIT_MS);
      QVERIFY(reply->error() != QNetworkReply::NoError);
    }

    void verifyPutJson(QString endpoint, const QByteArray& expected)
    {
      QByteArray result;
      TestUtils::requestValidPut(endpoint, result);
      TestUtils::verifyJson(result, expected);
    }

    void requestDelete(QString endpoint, QByteArray& result)
    {
      bool done = false;
      auto callback = [&result, &done](QNetworkReply* reply) {
                        result = reply->readAll();
                        done = true;
                      };
      QNetworkAccessManager* netMgr = new QNetworkAccessManager(qparent);
      QObject::connect(netMgr, &QNetworkAccessManager::finished, callback);
      QUrl url = endpoint;
      QNetworkReply* reply = netMgr->deleteResource(QNetworkRequest(url));
      QVERIFY(result.isEmpty());
      waitUntil(done, MAX_TEST_WAIT_MS);
      Q_UNUSED(reply);
    }

    void requestValidDelete(QString endpoint, QByteArray& result)
    {
      bool done = false;
      auto callback = [&result, &done](QNetworkReply* reply) {
                        result = reply->readAll();
                        done = true;
                      };
      QNetworkAccessManager* netMgr = new QNetworkAccessManager(qparent);
      QObject::connect(netMgr, &QNetworkAccessManager::finished, callback);
      QUrl url = endpoint;
      QNetworkReply* reply = netMgr->deleteResource(QNetworkRequest(url));
      QVERIFY(result.isEmpty());
      waitUntil(done, MAX_TEST_WAIT_MS);
      QCOMPARE(reply->error(), QNetworkReply::NoError);
    }

    void verifyDelete(QString endpoint, QNetworkReply::NetworkError error = QNetworkReply::NoError)
    {
      bool done = false;
      auto callback = [&done](QNetworkReply* reply) {
                        done = true;
                        Q_UNUSED(reply);
                      };
      QNetworkAccessManager* netMgr = new QNetworkAccessManager(qparent);
      QObject::connect(netMgr, &QNetworkAccessManager::finished, callback);
      QUrl url = endpoint;
      QNetworkReply* reply = netMgr->deleteResource(QNetworkRequest(url));
      waitUntil(done, MAX_TEST_WAIT_MS);
      QCOMPARE(reply->error(), error);
    }

    void verifyErrorDelete(QString endpoint)
    {
      bool done = false;
      auto callback = [&done](QNetworkReply* reply) {
                        done = true;
                        Q_UNUSED(reply);
                      };
      QNetworkAccessManager* netMgr = new QNetworkAccessManager(qparent);
      QObject::connect(netMgr, &QNetworkAccessManager::finished, callback);
      QUrl url = endpoint;
      QNetworkReply* reply = netMgr->deleteResource(QNetworkRequest(url));
      waitUntil(done, MAX_TEST_WAIT_MS);
      QVERIFY(reply->error() != QNetworkReply::NoError);
    }

    void verifyDeleteJson(QString endpoint, const QByteArray& expected)
    {
      QByteArray result;
      TestUtils::requestValidDelete(endpoint, result);
      TestUtils::verifyJson(result, expected);
    }
};

int TestUtils::MAX_TEST_WAIT_MS = 5000;

} // namespace test

} // namespace qttp

#endif // QTTPTESTUTILS_H
