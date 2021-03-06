#include "charsetdetector.hpp"
#include "misc/log.hpp"
#include <chardet.h>

DECLARE_LOG_CONTEXT(Charset)

struct CharsetDetector::Data {
    DetectObj *obj;
    bool detected;
};

CharsetDetector::CharsetDetector(const QByteArray &data)
: d(new Data) {
    d->obj = detect_obj_init();
    d->detected = (::detect(data.data(), &d->obj) == CHARDET_SUCCESS);
}

CharsetDetector::~CharsetDetector() {
    detect_obj_free(&d->obj);
    delete d;
}

auto CharsetDetector::isDetected() const -> bool
{
    return d->detected;
}

auto CharsetDetector::encoding() const -> QString
{
    if (d->detected) {
        const QString enc(_L(d->obj->encoding));
        if (enc.compare("EUC-KR"_a, Qt::CaseInsensitive) == 0)
            return u"CP949"_q;
        return enc;
    }
    return QString();
}

auto CharsetDetector::confidence() const -> double
{
    return d->detected ? d->obj->confidence : 0.0;
}


auto CharsetDetector::detect(const QByteArray &data, double confidence) -> QString
{
    CharsetDetector chardet(data);
    if (!chardet.isDetected()) {
        _Info("Failed to detect encoding.");
        return QString();
    }
    const auto enc = chardet.encoding();
    const auto conf = chardet.confidence();
    _Info("Encoding detected: %% (confidence: %%)", enc, conf);
    if (conf >= confidence)
        return enc;
    _Info("Through away detected encoding for low confidence < %%.", confidence);
    return QString();
}

auto CharsetDetector::detect(const QString &fileName, double confidence, int size) -> QString
{
    QFile file(fileName);
    if (!file.open(QFile::ReadOnly)) {
        _Error("Cannot open file: %%", fileName);
        return QString();
    }
    _Info("Trying encoding autodetection: %%", fileName);
    return detect(file.read(size), confidence);
}
