Summary: Bloonix DBI
Name: bloonix-dbi
Version: 0.15
Release: 1%{dist}
License: Commercial
Group: Utilities/System
Distribution: RHEL and CentOS

Packager: Jonny Schulz <js@bloonix.de>
Vendor: Bloonix

BuildArch: noarch
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root

Source0: http://download.bloonix.de/sources/%{name}-%{version}.tar.gz
Requires: bloonix-core >= 0.23
Requires: perl(DBI)
Requires: perl(DBD::Pg)
Requires: perl(DBD::mysql)
Requires: perl(Log::Handler)
Requires: perl(Params::Validate)
AutoReqProv: no

%description
bloonix-dbi provides a database interface.

%prep
%setup -q -n %{name}-%{version}

%build
%{__perl} Build.PL installdirs=vendor
%{__perl} Build

%install
%{__perl} Build install destdir=%{buildroot} create_packlist=0
find %{buildroot} -name .packlist -exec %{__rm} {} \;
find %{buildroot} -type f -name .packlist -exec rm -f {} ';'
find %{buildroot} -type f -name '*.bs' -a -size 0 -exec rm -f {} ';'
find %{buildroot} -type d -depth -exec rmdir {} 2>/dev/null ';'
%{_fixperms} %{buildroot}/*

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
%doc ChangeLog INSTALL LICENSE
%{perl_vendorlib}/*
%{_mandir}/man3/*

%changelog
* Tue Mar 29 2016 Jonny Schulz <js@bloonix.de> - 0.15-1
- Bloonix::SQL::Creator: it's now possible to use unknown functions
  like date_format().
* Tue Mar 29 2016 Jonny Schulz <js@bloonix.de> - 0.14-1
- Extra release because the gpg key of bloonix is updated.
* Sat Mar 19 2016 Jonny Schulz <js@bloonix.de> - 0.13-1
- Improved transaction handling.
* Mon Nov 16 2015 Jonny Schulz <js@bloonix.de> - 0.12-1
- Implement sum() in Bloonix::SQL::Creator.
- Bloonix::Validator is renamed to Bloonix::Validate.
* Fri Sep 18 2015 Jonny Schulz <js@bloonix.de> - 0.11-1
- If a search string begins with ^ then no pre % is add to
  like statements.
* Thu Aug 06 2015 Jonny Schulz <js@bloonix.de> - 0.10-1
- Now it's possible to lock multiple tables with one
  call of lock().
* Sat Jun 20 2015 Jonny Schulz <js@bloonix.de> - 0.9-1
- Fixed counting distinct rows.
* Sat Jun 20 2015 Jonny Schulz <js@bloonix.de> - 0.8-1
- Fixed concatenation of columns, specially for MySQL.
* Thu May 14 2015 Jonny Schulz <js@bloonix.de> - 0.7-1
- Fixed/added transactions support for mysql.
* Thu May 07 2015 Jonny Schulz <js@bloonix.de> - 0.6-1
- Added accessors driver and database.
- Improved string concatination and replaced || with concat().
* Mon Feb 16 2015 Jonny Schulz <js@bloonix.de> - 0.5-1
- Fixed error "prepared statement already exist".
* Mon Feb 16 2015 Jonny Schulz <js@bloonix.de> - 0.4-1
- Fixed sth_cache_enabled errors.
* Mon Nov 03 2014 Jonny Schulz <js@bloonix.de> - 0.3-1
- sth_cache_enabled is turned off by default now.
- Updated the license information.
* Fri Oct 24 2014 Jonny Schulz <js@bloonix.de> - 0.2-1
- Disable die_on_errors by default so that the logger
  does not die on errors.
* Mon Aug 25 2014 Jonny Schulz <js@bloonix.de> - 0.1-1
- Initial release.
