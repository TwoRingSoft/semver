set -e

#
# Build vrsn
#

if [[ ${VRSN_TRAVIS_BUILD:=0} -eq 1 ]]; then
    echo "travis_fold:start:Build vrsn"
    echo "Integration tests:"
    echo
fi

xcodebuild -project Vrsnr/Vrsnr.xcodeproj -scheme vrsn clean build | xcpretty

if [[ ${VRSN_TRAVIS_BUILD:=0} -eq 1 ]]; then
    echo "travis_fold:end:Build vrsn"
    echo
fi

#
# Integration tests
#

if [[ ${VRSN_TRAVIS_BUILD:=0} -eq 1 ]]; then
    echo "travis_fold:start:Integration tests"
    echo "Integration tests:"
    echo
fi

xcodebuild -project Vrsnr/Vrsnr.xcodeproj -scheme vrsnTests build

if [[ ${VRSN_TRAVIS_BUILD:=0} -eq 1 ]]; then
    echo "travis_fold:end:Integration tests"
    echo
fi

#
# Unit tests
#

if [[ ${VRSN_TRAVIS_BUILD:=0} -eq 1 ]]; then
    echo "travis_fold:start:Unit tests"
    echo "Unit tests:"
    echo
fi

xcodebuild -project Vrsnr/Vrsnr.xcodeproj -scheme VrsnrTests clean test | xcpretty

if [[ ${VRSN_TRAVIS_BUILD:=0} -eq 1 ]]; then
    echo "travis_fold:end:Unit tests"
    echo
fi
