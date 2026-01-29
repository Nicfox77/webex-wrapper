Name: webex-wrapper
Version: 1.0.0
Release: 1
Summary: Web-app wrapper for Cisco Webex using Nativefier
License: MIT
URL: https://www.webex.com/
Source0: webex-wrapper-installer.sh
Source1: LICENSE
Source2: README.md
BuildArch: noarch

Requires: bash
Requires: curl
Requires: nodejs
Requires: npm

%description
A web-app wrapper for Cisco Webex that creates a standalone desktop application
using Nativefier. This approach provides screen sharing support and avoids RPM
dependency issues by wrapping the Webex web interface as a native Linux application.

%prep
# Nothing to prep.

%build
# Nothing to build.

%install
install -Dpm 0755 %{SOURCE0} %{buildroot}%{_bindir}/webex-wrapper-installer.sh
install -Dpm 0644 %{SOURCE1} %{buildroot}%{_licensedir}/%{name}/LICENSE
install -Dpm 0644 %{SOURCE2} %{buildroot}%{_docdir}/%{name}/README.md

%files
%license %{_licensedir}/%{name}/LICENSE
%doc %{_docdir}/%{name}/README.md
%{_bindir}/webex-wrapper-installer.sh
