#!/bin/bash

echo "installing cfn-nag"
brew install ruby brew-gem
brew gem install cfn-nag

echo "installing cfn-lint"
brew install cfn-lint

echo "installing Semgrep"
brew install semgrep