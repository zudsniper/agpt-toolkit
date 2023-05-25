> # `YO!` This isn't _fully_ ready yet! 😞   
> I'm working on it, but this project is (as they always are) more than I had originally thought.   
>    I mean, I increased the scope myself, many times...  
> But I digress.   
> ### [**`LEGACY GEN2`**](https://gist.github.com/zudsniper/9af4c7c3f0de9f162a6b6316cb86ba7d)  
> To download this effectively, I suggest the following `curl` & then series of commands.    
> **PREREQUISITES**: `docker`, `python3.9+`, `npm`, `OpenAI API Key`, `RAM` & `SPACE` & `CPU`, `Kurtosis`.       
> ```sh
> # this will download & save the file as its received name
> $ curl -sL https://gist.githubusercontent.com/zudsniper/9af4c7c3f0de9f162a6b6316cb86ba7d/raw/agpt-pkg-gen2.sh -O
> # give the file executable permissions  
> $ sudo chmod ugo+x agpt-pkg-gen2.sh  
> # run the script to get a `sample-config.json`  
> $ ./agpt-pkg-gen2.sh INIT 
> # this will generate the file -- you need to make a `config.json` which has the correct settings. Good luck!  
> # once you do, try a cheeky one of these... (add a -n if you don't want it to automatically run the abominaation)   
> $ ./agpt-pkg-gen2.sh -d config.json # this will start the thing!  
> ```
> ### Check out [`@kurtosis-tech/autogpt-package`](https://github.com/kurtosis-tech/autogpt-package)!   
> Would not be possible without them.  
> **Finally, you can run this to become involved with your bot...**  
> <sup> _good luck._ </sup>  
> ```sh
> $ kurtosis service shell autogpt autogpt --exec "python -m autogpt"
> ```  
>    
> ---  

<details><summary><b><code>PRERELEASE README</code></b></summary>

<div align="center">

# `AutoGPT-Package Generator`   
<sup> _by [@zudsniper](https://gh.zod.tf)_ </sup>  
<img src="https://user-images.githubusercontent.com/16076573/235334036-4b0f9f31-2cf1-4bfc-b1d9-e87840cac8ec.png" alt="wills-computer" style="max-width: 100%;" width="240rem" />

</div>

> ### TECH-STACK from HELL 
> _via these projects, with highest abstraction level at the top..._      
> - [`@kurtosis-tech/autogpt-package`](https://github.com/kurtosis-tech/autogpt-package)  
> - [`@Significant-Gravitas/Auto-GPT-Plugins`](https://github.com/Significant-Gravitas/Auto-GPT-Plugins)   
> - [`@Significant-Gravitas/Auto-GPT`](https://github.com/Significant-Gravitas/Auto-GPT)   
> - [`OpenAI/ChatGPT`](https://chat.openai.com/) (GPT_[3.5-Turbo, 4.0])  
> - Many more! I blame NodeJS for all of this.  

---   

### "What The Fuck?"  
I don't know. This probably won't work -- but if it ever does, even for a moment, that would be **SO GOOD** for my procrastination.  

> _"Aren't you worried about the ethical implications of Artificial Intelligence?"_   
  
Yes.  

> _"Then why are yo-"_   
  
SSSsssshhhhh. Wanted to.  

---  

# AutoGPT-Package Generator

AutoGPT-Package Generator is a powerful and versatile tool for generating, configuring, and managing GPT-powered software packages. This document covers the usage of the tool, including its subcommands, flags, and options, as well as providing examples to showcase its capabilities.

## Table of Contents

- [Dependencies](#dependencies)
- [Subcommands](#subcommands)
  - [INIT](#init)
  - [CONFIGURE](#configure)
  - [MAKE](#make)
  - [LIST](#list)
  - [EXEC](#exec)
  - [PLUGIN](#plugin)
    - [STATUS](#status)
    - [START](#start)
    - [STOP](#stop)
    - [INSTALL](#install)
    - [REMOVE](#remove)
  - [BREAK](#break)
  - [SFTP](#sftp)
  - [FUCK](#fuck)
- [Flags](#flags)
- [Examples](#examples)

## Dependencies

Before using the AutoGPT-Package Generator, ensure you have the following software installed:

- Docker (version 20.10.0 or higher 😟)
- Kurtosis (version 0.1.0 or higher 😟)
- AutoGPT-Package (version 1.0.0 or higher 😟)

## Subcommands

### INIT

The `INIT` subcommand initializes a new AutoGPT-Package project, creating a `sample-config.json`. It takes no arguments.

Usage:

```bash
./agpt-pkg-gen.sh INIT
```

### CONFIGURE

The `CONFIGURE` subcommand allows you to interactively set up and modify your `config.json` file. The script will guide you through setting up the required and optional environment variables for your project.

Usage:

```bash
./agpt-pkg-gen.sh CONFIGURE [options] <Name | DockerID> <<KEY>=<VALUE>>
```

### MAKE

The `MAKE` subcommand generates a new GPT-powered software package with the specified configuration.

Usage:

```bash
./agpt-pkg-gen.sh MAKE [options] <Name | DockerID> <Executable>=(default)/bin/bash
```

### LIST

The `LIST` subcommand displays a list of available GPT models and their properties. It can also be used with specific flags to filter the output based on certain criteria.

Usage:

```bash
./agpt-pkg-gen.sh LIST [--flag]
```

### EXEC

The `EXEC` subcommand executes a specific GPT package, given its name.

Usage:

```bash
./agpt-pkg-gen.sh EXEC [options] <Name | DockerID> <executable>=(default)/bin/bash
```

### PLUGIN

The `PLUGIN` subcommand allows you to manage plugins for your GPT package.

Usage:

```bash
./agpt-pkg-gen.sh PLUGIN [options] <Name | DockerID> {PLUGIN_SUBCOMMAND} <Plugin_Name>@<PluginVersion>?
```

#### STATUS

The `STATUS` subcommand shows status information about the specified plugin or lists all plugins if no plugin is provided as an argument.

Usage:

```bash
./agpt-pkg-gen.sh PLUGIN [options] <Name | DockerID> STATUS <Plugin_Name>@<PluginVersion>?
```

#### START

The `START` subcommand starts the specified plugin.

Usage:

```bash
./agpt-pkg-gen.sh PLUGIN [options] <Name | DockerID> START
```

#### STOP

The `STOP` subcommand stops the specified plugin.

Usage:

```bash
./agpt-pkg-gen.sh PLUGIN [options] <Name | DockerID> STOP
```

#### INSTALL

The `INSTALL` subcommand installs a plugin for your GPT package, given its name and version.

Usage:

```bash
./agpt-pkg-gen.sh PLUGIN [options] <Name | DockerID> INSTALL <Plugin_Name>@<PluginVersion>?
```

#### REMOVE

The `REMOVE` subcommand removes a plugin from your GPT package, given its name and version.

Usage:

```bash
./agpt-pkg-gen.sh PLUGIN [options] <Name | DockerID> REMOVE <Plugin_Name>@<PluginVersion>?
```

### BREAK

The `BREAK` subcommand safely tears down an AutoGPT-Package Docker container.

Usage:

```bash
./agpt-pkg-gen.sh BREAK [options] <Name | DockerID>
```

### SFTP

The `SFTP` subcommand generates an SFTP link for your GPT instance, allowing you to manage files within the instance.

Usage:

```bash
./agpt-pkg-gen.sh SFTP [options] <Name | DockerID>
```

### FUCK

The `FUCK` subcommand is a panic command that dumps the disk volume of the specified GPT instance and immediately shuts it down without deleting it.

Usage:

```bash
./agpt-pkg-gen.sh FUCK [options] <Name | DockerID>
```

## Flags
> `[TODO]` _These are fucking wrong, come back to this @zudsniper_  


| Flag         | Description                                                                                                                                                                                                 |
|--------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| -i, --input  | Specify an input file                                                                                                                                                                                        |
| -o, --output | Specify an output file                                                                                                                                                                                       |
| -f, --file   | Specify a file for various subcommands                                                                                                                                                                       |
| -u, --update | Update configuration settings                                                                                                                                                                                |
| -n, --name   | Specify a name for a GPT instance                                                                                                                                                                            |
| -h, --help   | Display help information                                                                                                                                                                                     |
| -v, --version | Display the version information of the script and exit                                                                                                                                                       |
| -m, --manual | Disable interactive configuration for plugin installation and display a warning message instead                                                                                                              |
| -y, --yes    | Bypass confirmation prompts for certain subcommands                                                                                                                                                          |
| --force      | Force certain actions, overriding default behavior                                                                                                                                                           |
| --verbose    | Enable verbose output for certain subcommands                                                                                                                                                                |

## Examples

1. Initialize a new AutoGPT-Package project:

```bash
./agpt-pkg-gen.sh INIT
```

2. Configure an AutoGPT-Package project:

```bash
./agpt-pkg-gen.sh CONFIGURE example_name OPENAI_API_KEY=my_key
```

3. Make a GPT-powered software package:

```bash
./agpt-pkg-gen.sh MAKE example_name
```

4. List available GPT models:

```bash
./agpt-pkg-gen.sh LIST
```

5. Execute a specific GPT package:

```bash
./agpt-pkg-gen.sh EXEC example_name
```

6. Install a plugin for your GPT package:

```bash
./agpt-pkg-gen.sh PLUGIN example_name INSTALL plugin_name@1.0.0
```

7. Safely tear down a GPT instance:

```bash
./agpt-pkg-gen.sh BREAK example_name
```

8. Generate an SFTP link for a GPT instance:

```bash
./agpt-pkg-gen.sh SFTP example_name
```

9. Panic command for a GPT instance:

```bash
./agpt-pkg-gen.sh FUCK example
```

---  

</details>

<div align="center">

### 💙 SUPPORT ME 💗 
[![Donate](https://img.shields.io/static/v1?label=&message=Donate&color=ff69b4&logo=Github+Sponsors&logoColor=ffffff)](https://zod.tf/donate) 
[![Steam Items](https://img.shields.io/static/v1?label=&message=Steam+Items&color=informational&logo=Github+Sponsors&logoColor=ffffff)](https://zod.tf/donate_items)  
This took a long time, even with the infinite robots!  

### 🎁🧨🎈

</div>  
