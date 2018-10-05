cmake_minimum_required (VERSION 3.12)
project (AdversarialVoice)

set(CorrelatorSrc Wave.cpp)

add_executable(Corrrelator ${CorrelatorSrc})
