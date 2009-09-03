package WWW::HtmlUnit;

=head1 NAME

WWW::HtmlUnit - Inline::Java based wrapper of the HtmlUnit v2.5 library

=head1 SYNOPSIS

  use WWW::HtmlUnit;
  my $webClient = WWW::HtmlUnit->new;
  my $page = $webClient->getPage("http://google.com/");
  my $f = $page->getFormByName('f');
  my $submit = $f->getInputByName("btnG");
  my $query  = $f->getInputByName("q");
  $page = $query->type("HtmlUnit");
  $page = $query->type("\n");

  my $content = $page->asXml;
  print "Result:\n$content\n\n";

=head1 DESCRIPTION

This is a wrapper around the HtmlUnit library (HtmlUnit version 2.5 for this
release). It includes the HtmlUnit jar itself and it's dependencies. All this
library really does is find the jars and load them up using Inline::Java.

The reason all this is interesting? HtmlUnit has very good javascript support,
so you can automate, scrape, or test javascript-required websites.

See especially the HtmlUnit documentation on their site for deeper API
documentation, L<http://htmlunit.sourceforge.net/apidocs/>.

=head1 INSTALLING

There is one problem that I fun into when installing Inline::Java, and thus
WWW::HtmlUnit, which is telling the installer where to find your java home. It
turns out this is really really easy, just define the JAVA_HOME environment
variable before you start your CPAN shell / installer. I do this in
Debian/Ubuntu:

  apt-get install sun-java6-jdk
  JAVA_HOME=/usr/lib/jvm/java-6-sun cpan WWW::HtmlUnit

and everything works the way I want! I should submit a patch to the error
message that Inline::Java spits out...

=cut

use strict;
use warnings;

our $VERSION = '0.06';

sub find_jar_path {
    my $self = shift;
    my $path = $INC{'WWW/HtmlUnit.pm'};
    $path =~ s/\.pm$/\/jar/;
    return $path;
}

# This way might be better?
# use File::Find;
# sub find_jar_path {
    # my $self = shift;
    # my $module = 'WWW/HtmlUnit';
    # $module =~ s/\*$/.*/;
    # 
    # my $found = {};
    # my @module_path;
    # find {
        # wanted => sub {
            # my $path = $File::Find::name;
            # return if -d $_;
            # push @module_path, $path if $path =~ /[\\\/]$module.pm$/i;
        # },
    # }, grep {-d $_ and $_ ne '.'} @INC;
    # print "Mod path: @module_path\n";
    # my $path = shift @module_path;
    # $path =~ s/\/$module.pm$//;
    # $path = "$path/WWW/HtmlUnit/jar";
    # print "Path: $path\n";
    # return $path;
# }

sub collect_default_jars {
    my $jar_path = find_jar_path();
    return join ':', map { "$jar_path/$_" } qw(
      commons-codec-1.4.jar
      commons-collections-3.2.1.jar
      commons-httpclient-3.1.jar
      commons-io-1.4.jar
      commons-lang-2.4.jar
      commons-logging-1.1.1.jar
      cssparser-0.9.5.jar
      htmlunit-2.6.jar
      htmlunit-core-js-2.6.jar
      nekohtml-1.9.13.jar
      sac-1.3.jar
      serializer-2.7.1.jar
      xalan-2.7.1.jar
      xercesImpl-2.9.1.jar
      xml-apis-1.3.04.jar
    );
}

=head1 MODULE IMPORT PARAMETERS

If you need to include extra .jar files, you can do:

  use HtmlUnit jars => ['/path/to/blah.jar'];

and that wil be added to the list of jars for Inline::Java to autostudy.

=cut

sub import {
    my $class = shift;
    my %parameters = @_;
    my $custom_jars = "";
    if ($parameters{jars}) {
        $custom_jars = join(':', @{$parameters{jars}});
    }

    require Inline;
    Inline->import(
      Java => 'STUDY',
      STUDY => [
        'com.gargoylesoftware.htmlunit.WebClient',
        'com.gargoylesoftware.htmlunit.BrowserVersion',
      ],
      AUTOSTUDY => 1,
      CLASSPATH => collect_default_jars() . ":" . $custom_jars
    );
}

=head1 METHODS

=head2 $webClient = WWW::HtmlUnit->new($browser_name)

This is just a shortcut for 

  $webClient = WWW::HtmlUnit::com::gargoylesoftware::htmlunit::WebClient->new;

The optional $browser_name allows you to specify which browser version to pass
to the WebClient->new method. You could pass "FIREFOX_3" for example, to make
the engine especially try to emulate Firefox 3 quirks, I imagine.

=cut

sub new {
  my ($class, $version) = @_;
  if($version) {
    my $browser_version = eval "\$WWW::HtmlUnit::com::gargoylesoftware::htmlunit::BrowserVersion::$version";
    return WWW::HtmlUnit::com::gargoylesoftware::htmlunit::WebClient->new($browser_version);
  } else {
    return WWW::HtmlUnit::com::gargoylesoftware::htmlunit::WebClient->new;
  }
}

=head1 DEPENDENCIES

When installed using the CPAN shell, all dependencies besides java itself will
be installed. This includes the HtmlUnit jar files, and in fact those files
make up the bulk of the distribution.

=head1 TIPS

How do I do HTTP authentication?

  my $credentialsProvider = $webclient->getCredentialsProvider;                           
  $credentialsProvider->addCredentials($username, $password);                

How do I turn off SSL certificate checking?

  $webclient->setUseInsecureSSL(1);

=head1 TODO

=over 4

=item * Capture HtmlUnit output to a variable

=item * Use that to have a quiet-mode

=back

=head1 SEE ALSO

L<http://htmlunit.sourceforge.net/>, L<Inline::Java>

=head1 AUTHOR

  Brock Wilcox <awwaiid@thelackthereof.org> - http://thelackthereof.org/

=head1 COPYRIGHT

  Copyright (c) 2009 Brock Wilcox <awwaiid@thelackthereof.org>. All rights
  reserved.  This program is free software; you can redistribute it and/or
  modify it under the same terms as Perl itself.

  HtmlUnit library includes the following copyright:

      Copyright (c) 2002-2009 Gargoyle Software Inc.

      Licensed under the Apache License, Version 2.0 (the "License");
      you may not use this file except in compliance with the License.
      You may obtain a copy of the License at
      http://www.apache.org/licenses/LICENSE-2.0

      Unless required by applicable law or agreed to in writing, software
      distributed under the License is distributed on an "AS IS" BASIS,
      WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
      See the License for the specific language governing permissions and
      limitations under the License.

=cut

1;

