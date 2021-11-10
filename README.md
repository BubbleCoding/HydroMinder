<div align="center"> 
  <p align="center">
    <img src="https://i.imgur.com/uBzEyGT.png" width="256" alt="HydroMinder Logo" />
  </p>

  <h1 align="center">HydroMinder Installer</h1>
  <p align="center">A modern hydration tracker for anyone.</p>
</div>

## Description

This is the installer for HydroMinder.

## Requirements

-   curl

## All-In-One Install Command

```bash
$ curl -fsSL https://gitlab.utwente.nl/cs21-32/hydrominderscripts/-/raw/master/install.sh | sudo bash -s
```

## Updating Existing Installations

```bash
$ curl -fsSL https://gitlab.utwente.nl/cs21-32/hydrominderscripts/-/raw/master/update.sh | sudo bash -s
```

## Disclaimer

We, Team 32, do not provide any warranty and are not responsible for any damages caused by possible issues and misconfigurations in our code (Web App, API, Controller, and Scripts).  
We have done our best to make a secure product, but there are a few things out of our control or simply unfeasable. Because of this we recommend the following:  
- Choose strong passwords
- Keep an eye on your network (if it's compromised the availability cannot be guaranteed)
- Keep an eye on the physical device (there are no protections in place when the physical device has been compromised)
- Verify the TLS key's fingerprint with the one displayed on the LCD

## Privacy

HydroMinder itself does not share any personal data with us or third-parties. HydroMinder itself is fully [GDPR compliant](https://gdpr.eu/).

However, there will be comunication with third-parties when installing the required software.  
For the related third parties, please familiarize yourself with these
privacy policies:

-   [GitLab Privacy Policy](https://about.gitlab.com/privacy/)
-   [Docker Privacy Policy](https://www.docker.com/legal/docker-privacy-policy)

## License

HydroMinder Scripts is [MIT licensed](LICENSE).
