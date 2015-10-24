Name:       jolla-settings-tor-button

# >> macros
BuildArch: noarch
# << macros

Summary:    Settings plugin adding tor control button
Version:    0.1.0
Release:    1
Group:      Qt/Qt
License:    TODO
Source0:    %{name}-%{version}.tar.bz2
Requires:   tor

%description
Settings plugin adding tor control button


%prep
%setup -q -n %{name}-%{version}

# >> setup
# << setup

%build
# >> build pre
# << build pre

# >> build post
# << build post

%install
rm -rf %{buildroot}
# >> install pre
mkdir -p %{buildroot}/usr/bin
cp -r settings/*.sh %{buildroot}/usr/bin
mkdir -p %{buildroot}/usr/share/jolla-settings/pages/tor
cp -r settings/*.qml %{buildroot}/usr/share/jolla-settings/pages/tor
cp -r settings/*.js %{buildroot}/usr/share/jolla-settings/pages/tor
mkdir -p %{buildroot}/usr/share/jolla-settings/entries
cp -r settings/*.json %{buildroot}/usr/share/jolla-settings/entries
mkdir -p %{buildroot}/usr/share/themes/jolla-ambient/meegotouch/icons
cp -r icons/*.png %{buildroot}/usr/share/themes/jolla-ambient/meegotouch/icons
# << install pre

# >> install post
# << install post

%files
%defattr(-,root,root,-)
%attr(0755, root, root) %{_bindir}/*
%{_datadir}/jolla-settings/entries
%{_datadir}/jolla-settings/pages
%{_datadir}/themes/jolla-ambient/meegotouch/icons
# >> files
# << files
