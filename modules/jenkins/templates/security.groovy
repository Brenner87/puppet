import jenkins.model.*
import hudson.security.*
import jenkins.security.s2m.AdminWhitelistRule
import hudson.security.csrf.DefaultCrumbIssuer
import jenkins.model.Jenkins
import jenkins.install.*;
import hudson.util.*;
import hudson.tasks.*;
import jenkins.*
import jenkins.model.*
import hudson.*
import hudson.model.*

def instance = Jenkins.getInstance()

def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount("admin","1qazxsw2")
instance.setSecurityRealm(hudsonRealm)
instance.setInstallState(InstallState.INITIAL_SETUP_COMPLETED)

def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
instance.setAuthorizationStrategy(strategy)
instance.save()

Jenkins.instance.getInjector().getInstance(AdminWhitelistRule.class)

def j = Jenkins.instance
if (j.getCrumbIssuer() == null) {
    j.setCrumbIssuer(new DefaultCrumbIssuer(true))
    j.save()
    println 'CSRF Protection configuration has changed. Enabled CSRF Protection'}
else {
    println 'Nothing changed. CSRF Protection already configured'
}

a=Jenkins.instance.getExtensionList(hudson.tasks.Maven.DescriptorImpl.class)[0];
b=(a.installations as List);
b.add(new hudson.tasks.Maven.MavenInstallation("mvn", "/home/maven", []));
a.installations=b
a.save()
