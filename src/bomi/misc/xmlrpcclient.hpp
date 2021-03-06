#ifndef XMLRPCCLIENT_HPP
#define XMLRPCCLIENT_HPP

#include <QNetworkReply>

class XmlRpcClient : public QObject {
    Q_OBJECT
public:
    using Connection = QMetaObject::Connection;
    static auto pass(const QVariantList &) -> void {}
    XmlRpcClient(QObject *parent = nullptr);
    ~XmlRpcClient();
    auto setUrl(const QUrl &url) -> void;
    auto setCompressed(bool compressed) -> void;
    auto isCompressed() const -> bool;
    template<class F = decltype(pass)>
    auto call(const QString &method, F onFinished = pass) -> Connection;
    template<class F = decltype(pass)>
    auto call(const QString &method, const QVariantList &args,
              F onFinished = pass) -> Connection;
    auto postCall(const QString &method,
                  const QVariantList &args = QVariantList()) -> QNetworkReply*;
    auto lastCall() const -> QString;
private:
    static auto parseResponse(const QByteArray &reply,
                              bool compressed) -> QVariantList;
    struct Data;
    Data *d;
};

template<class F>
inline auto XmlRpcClient::call(const QString &method,
                               F onFinished) -> QMetaObject::Connection
{ return call(method, QVariantList(), onFinished); }

template<class F>
inline auto XmlRpcClient::call(const QString &method,
                               const QVariantList &args,
                               F onFinished) -> QMetaObject::Connection
{
    auto r = postCall(method, args);
    const bool comp = isCompressed();
    return connect(r, &QNetworkReply::finished, [onFinished, r, comp] () {
        onFinished(parseResponse(r->readAll(), comp));
        r->deleteLater();
    });
}

#endif // XMLRPCCLIENT_HPP
