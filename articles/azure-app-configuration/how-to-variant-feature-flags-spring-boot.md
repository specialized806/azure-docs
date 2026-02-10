---
title: 'Use variant feature flags in a Spring Boot application'
titleSuffix: Azure App Configuration
description: In this tutorial, you learn how to use variant feature flags in a Spring Boot application
#customerintent: As a user of Azure App Configuration, I want to learn how I can use variants and variant feature flags in my Spring Boot application.
author: mrm9084
ms.author: mametcal
ms.service: azure-app-configuration
ms.devlang: java
ms.topic: tutorial
ms.date: 02/10/2026
---

# Tutorial: Use variant feature flags in a Spring Boot application

In this tutorial, you use a variant feature flag to manage experiences for different user segments in an example application, *Quote of the Day*. You utilize the variant feature flag created in [Use variant feature flags](./howto-variant-feature-flags.md). Before proceeding, ensure you create the variant feature flag named *Greeting* in your App Configuration store.

## Prerequisites

* A supported [Java Development Kit (JDK)](/java/azure/jdk) with version 17 or later.
* [Apache Maven](https://maven.apache.org/download.cgi) version 3.0 or later.
* Follow the [Use variant feature flags](./howto-variant-feature-flags.md) tutorial and create the variant feature flag named *Greeting*.

## Set up a Spring Boot web app

If you already have a Spring Boot web app with authentication, you can skip to the [Use the variant feature flag](#use-the-variant-feature-flag) section.

1. Browse to the [Spring Initializr](https://start.spring.io) and create a new project with the following options:
    * Generate a **Maven** project with **Java**.
    * Specify a **Spring Boot** version that's 3.0 or later.
    * Set the **Group** to `com.example` and **Artifact** to `quoteoftheday`.
    * Add the **Spring Web**, **Thymeleaf**, and **Spring Security** dependencies.

1. After you specify the options, select **Generate** to download the project. Extract the files to your local system.

1. Open the *pom.xml* file and add the Spring Data JPA and H2 dependencies for user authentication:

    ```xml
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-thymeleaf</artifactId>
        <scope>compile</scope>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-security</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    <dependency>
        <groupId>com.h2database</groupId>
        <artifactId>h2</artifactId>
        <scope>runtime</scope>
    </dependency>
    ```

## Create the Quote of the Day app

1. Create a new file named *Quote.java* in the `src/main/java/com/example/quoteoftheday` folder with the following content. It defines a data class for quotes.

    ```java
    package com.example.quoteoftheday;

    public record Quote(String message, String author) {
    }
    ```

1. Create a new file named *User.java* in the same folder with the following content. It defines the user entity for authentication.

    ```java
    package com.example.quoteoftheday;

    import jakarta.persistence.Entity;
    import jakarta.persistence.GeneratedValue;
    import jakarta.persistence.GenerationType;
    import jakarta.persistence.Id;
    import jakarta.persistence.Table;

    @Entity
    @Table(name = "users")
    public class User {

        @Id
        @GeneratedValue(strategy = GenerationType.IDENTITY)
        private Long id;

        private String username;

        private String password;

        public User() {
        }

        public User(String username, String password) {
            this.username = username;
            this.password = password;
        }

        public Long getId() {
            return id;
        }

        public void setId(Long id) {
            this.id = id;
        }

        public String getUsername() {
            return username;
        }

        public void setUsername(String username) {
            this.username = username;
        }

        public String getPassword() {
            return password;
        }

        public void setPassword(String password) {
            this.password = password;
        }
    }
    ```

1. Create a new file named *UserRepository.java* with the following content:

    ```java
    package com.example.quoteoftheday;

    import java.util.Optional;

    import org.springframework.data.jpa.repository.JpaRepository;

    public interface UserRepository extends JpaRepository<User, Long> {
        Optional<User> findByUsername(String username);
    }
    ```

1. Create a new file named *CustomUserDetailsService.java* with the following content:

    ```java
    package com.example.quoteoftheday;

    import org.springframework.security.core.userdetails.UserDetails;
    import org.springframework.security.core.userdetails.UserDetailsService;
    import org.springframework.security.core.userdetails.UsernameNotFoundException;
    import org.springframework.stereotype.Service;

    @Service
    public class CustomUserDetailsService implements UserDetailsService {

        private final UserRepository userRepository;

        public CustomUserDetailsService(UserRepository userRepository) {
            this.userRepository = userRepository;
        }

        @Override
        public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
            User user = userRepository.findByUsername(username)
                    .orElseThrow(() -> new UsernameNotFoundException("User not found: " + username));

            return org.springframework.security.core.userdetails.User.builder()
                    .username(user.getUsername())
                    .password(user.getPassword())
                    .roles("USER")
                    .build();
        }
    }
    ```

1. Create a new file named *SecurityConfig.java* with the following content to configure Spring Security:

    ```java
    package com.example.quoteoftheday;

    import org.springframework.context.annotation.Bean;
    import org.springframework.context.annotation.Configuration;
    import org.springframework.security.config.annotation.web.builders.HttpSecurity;
    import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
    import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
    import org.springframework.security.crypto.password.PasswordEncoder;
    import org.springframework.security.web.SecurityFilterChain;

    @Configuration
    @EnableWebSecurity
    public class SecurityConfig {

        @Bean
        public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
            http
                    .authorizeHttpRequests(auth -> auth
                            .requestMatchers("/register", "/css/**").permitAll()
                            .anyRequest().permitAll())
                    .formLogin(form -> form
                            .loginPage("/login")
                            .defaultSuccessUrl("/", true)
                            .permitAll())
                    .logout(logout -> logout
                            .logoutSuccessUrl("/")
                            .permitAll());
            return http.build();
        }

        @Bean
        public PasswordEncoder passwordEncoder() {
            return new BCryptPasswordEncoder();
        }
    }
    ```

1. Create a new file named *HomeController.java* with the following content. It handles the home page display with a random quote.

    ```java
    package com.example.quoteoftheday;

    import java.security.Principal;
    import java.util.List;
    import java.util.Random;

    import org.springframework.stereotype.Controller;
    import org.springframework.ui.Model;
    import org.springframework.web.bind.annotation.GetMapping;

    @Controller
    public class HomeController {

        private final List<Quote> quotes = List.of(
                new Quote("You cannot change what you are, only what you do.", "Philip Pullman"));

        private final Random random = new Random();

        @GetMapping("/")
        public String index(Model model, Principal principal) {
            String username = "Guest";
            if (principal != null) {
                username = principal.getName();
            }
            model.addAttribute("user", username);
            model.addAttribute("isAuthenticated", principal != null);

            String greetingMessage = "Hi";
            model.addAttribute("greetingMessage", greetingMessage);
            model.addAttribute("quote", quotes.get(random.nextInt(quotes.size())));

            return "index";
        }
    }
    ```

1. Create a new file named *AuthController.java* with the following content to handle user registration:

    ```java
    package com.example.quoteoftheday;

    import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
    import org.springframework.security.core.context.SecurityContextHolder;
    import org.springframework.security.core.userdetails.UserDetails;
    import org.springframework.security.crypto.password.PasswordEncoder;
    import org.springframework.stereotype.Controller;
    import org.springframework.web.bind.annotation.GetMapping;
    import org.springframework.web.bind.annotation.PostMapping;
    import org.springframework.web.bind.annotation.RequestParam;

    @Controller
    public class AuthController {

        private final UserRepository userRepository;
        private final PasswordEncoder passwordEncoder;
        private final CustomUserDetailsService userDetailsService;

        public AuthController(UserRepository userRepository, PasswordEncoder passwordEncoder,
                CustomUserDetailsService userDetailsService) {
            this.userRepository = userRepository;
            this.passwordEncoder = passwordEncoder;
            this.userDetailsService = userDetailsService;
        }

        @GetMapping("/register")
        public String registerForm() {
            return "register";
        }

        @PostMapping("/register")
        public String register(@RequestParam String username, @RequestParam String password) {
            if (userRepository.findByUsername(username).isPresent()) {
                return "redirect:/register?error";
            }

            User user = new User(username, passwordEncoder.encode(password));
            userRepository.save(user);

            // Auto-login after registration
            UserDetails userDetails = userDetailsService.loadUserByUsername(username);
            UsernamePasswordAuthenticationToken auth = new UsernamePasswordAuthenticationToken(userDetails, null,
                    userDetails.getAuthorities());
            SecurityContextHolder.getContext().setAuthentication(auth);

            return "redirect:/";
        }

        @GetMapping("/login")
        public String loginForm() {
            return "login";
        }
    }
    ```

1. Create the *templates* directory at `src/main/resources/templates` and add a new file named *index.html* with the following content:

    ```html
    <!DOCTYPE html>
    <html lang="en" xmlns:th="http://www.thymeleaf.org">
    <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>QuoteOfTheDay</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"
            integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
        <link rel="stylesheet" th:href="@{/css/site.css}">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
    </head>
    <body>
        <header>
            <nav class="navbar navbar-expand-sm navbar-toggleable-sm navbar-light bg-white border-bottom box-shadow mb-3">
                <div class="container">
                    <a class="navbar-brand" href="/">QuoteOfTheDay</a>
                    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target=".navbar-collapse"
                        aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
                        <span class="navbar-toggler-icon"></span>
                    </button>
                    <div class="navbar-collapse collapse d-sm-inline-flex justify-content-between">
                        <ul class="navbar-nav flex-grow-1">
                            <li class="nav-item">
                                <a class="nav-link text-dark" href="/">Home</a>
                            </li>
                        </ul>
                        <ul class="navbar-nav">
                            <li class="nav-item" th:if="${isAuthenticated}">
                                <span class="nav-link text-dark">Hello <span th:text="${user}"></span>!</span>
                            </li>
                            <li class="nav-item" th:if="${isAuthenticated}">
                                <form th:action="@{/logout}" method="post" style="display: inline;">
                                    <button type="submit" class="nav-link text-dark btn btn-link">Logout</button>
                                </form>
                            </li>
                            <li class="nav-item" th:unless="${isAuthenticated}">
                                <a class="nav-link text-dark" href="/register">Register</a>
                            </li>
                            <li class="nav-item" th:unless="${isAuthenticated}">
                                <a class="nav-link text-dark" href="/login">Login</a>
                            </li>
                        </ul>
                    </div>
                </div>
            </nav>
        </header>
        <div class="container">
            <main role="main" class="pb-3">
                <div class="quote-container">
                    <div class="quote-content">
                        <h3 class="greeting-content" th:if="${greetingMessage}" th:text="${greetingMessage}"></h3>
                        <br />
                        <p class="quote">"<span th:text="${quote.message}"></span>"</p>
                        <p>- <b th:text="${quote.author}"></b></p>
                    </div>

                    <div class="vote-container">
                        <button class="btn btn-primary" onclick="heartClicked(this)">
                            <i class="far fa-heart"></i>
                        </button>
                    </div>
                </div>
            </main>
        </div>
        <footer class="border-top footer text-muted">
            <div class="container">
                &copy; 2024 - QuoteOfTheDay
            </div>
        </footer>
        <script src="https://code.jquery.com/jquery-3.7.1.min.js"
            integrity="sha256-/JqT3SQfawRcv/BIHPThkBvs0OEvtFFmqPF/lYI/Cxo=" crossorigin="anonymous"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
            integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
            crossorigin="anonymous"></script>
        <script>
            function heartClicked(button) {
                var icon = button.querySelector('i');
                icon.classList.toggle('far');
                icon.classList.toggle('fas');
            }
        </script>
    </body>
    </html>
    ```

1. Create a new file named *register.html* in the *templates* directory with the following content:

    ```html
    <!DOCTYPE html>
    <html lang="en" xmlns:th="http://www.thymeleaf.org">
    <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>Register - QuoteOfTheDay</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"
            integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
        <link rel="stylesheet" th:href="@{/css/site.css}">
    </head>
    <body>
        <header>
            <nav class="navbar navbar-expand-sm navbar-toggleable-sm navbar-light bg-white border-bottom box-shadow mb-3">
                <div class="container">
                    <a class="navbar-brand" href="/">QuoteOfTheDay</a>
                </div>
            </nav>
        </header>
        <div class="container">
            <main role="main" class="pb-3">
                <div class="login-container">
                    <h1>Create an account</h1>
                    <div th:if="${param.error}" class="alert alert-danger">Username already exists</div>
                    <form th:action="@{/register}" method="post">
                        <div class="mb-3">
                            <label for="username" class="form-label">Username:</label>
                            <input type="text" name="username" id="username" class="form-control" required />
                        </div>
                        <div class="mb-3">
                            <label for="password" class="form-label">Password:</label>
                            <input type="password" name="password" id="password" class="form-control" required />
                        </div>
                        <button type="submit" class="btn btn-primary">Submit</button>
                    </form>
                </div>
            </main>
        </div>
        <footer class="border-top footer text-muted">
            <div class="container">
                &copy; 2024 - QuoteOfTheDay
            </div>
        </footer>
    </body>
    </html>
    ```

1. Create a new file named *login.html* in the *templates* directory with the following content:

    ```html
    <!DOCTYPE html>
    <html lang="en" xmlns:th="http://www.thymeleaf.org">
    <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>Login - QuoteOfTheDay</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"
            integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
        <link rel="stylesheet" th:href="@{/css/site.css}">
    </head>
    <body>
        <header>
            <nav class="navbar navbar-expand-sm navbar-toggleable-sm navbar-light bg-white border-bottom box-shadow mb-3">
                <div class="container">
                    <a class="navbar-brand" href="/">QuoteOfTheDay</a>
                </div>
            </nav>
        </header>
        <div class="container">
            <main role="main" class="pb-3">
                <div class="login-container">
                    <h1>Login to your account</h1>
                    <div th:if="${param.error}" class="alert alert-danger">Invalid username or password</div>
                    <form th:action="@{/login}" method="post">
                        <div class="mb-3">
                            <label for="username" class="form-label">Username:</label>
                            <input type="text" name="username" id="username" class="form-control" required />
                        </div>
                        <div class="mb-3">
                            <label for="password" class="form-label">Password:</label>
                            <input type="password" name="password" id="password" class="form-control" required />
                        </div>
                        <button type="submit" class="btn btn-primary">Submit</button>
                    </form>
                </div>
            </main>
        </div>
        <footer class="border-top footer text-muted">
            <div class="container">
                &copy; 2024 - QuoteOfTheDay
            </div>
        </footer>
    </body>
    </html>
    ```

1. Create the *static/css* directory at `src/main/resources/static/css` and add a new file named *site.css* with the following content:

    ```css
    html {
        font-size: 14px;
    }

    @media (min-width: 768px) {
        html {
            font-size: 16px;
        }
    }

    .btn:focus,
    .btn:active:focus,
    .btn-link.nav-link:focus,
    .form-control:focus,
    .form-check-input:focus {
        box-shadow: 0 0 0 0.1rem white, 0 0 0 0.25rem #258cfb;
    }

    html {
        position: relative;
        min-height: 100%;
    }

    body {
        margin-bottom: 60px;
    }

    body {
        font-family: Arial, sans-serif;
        background-color: #f4f4f4;
        color: #333;
    }

    .quote-container {
        background-color: #fff;
        margin: 2em auto;
        padding: 2em;
        border-radius: 8px;
        max-width: 750px;
        box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.2);
        display: flex;
        justify-content: space-between;
        align-items: start;
        position: relative;
    }

    .login-container {
        background-color: #fff;
        margin: 2em auto;
        padding: 2em;
        border-radius: 8px;
        max-width: 750px;
        box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.2);
        justify-content: space-between;
        align-items: start;
        position: relative;
    }

    .vote-container {
        position: absolute;
        top: 10px;
        right: 10px;
        display: flex;
        gap: 0em;
    }

    .vote-container .btn {
        background-color: #ffffff;
        border-color: #ffffff;
        color: #333
    }

    .vote-container .btn:focus {
        outline: none;
        box-shadow: none;
    }

    .vote-container .btn:hover {
        background-color: #F0F0F0;
    }

    .greeting-content {
        font-family: 'Georgia', serif;
    }

    .quote-content p.quote {
        font-size: 2em;
        font-family: 'Georgia', serif;
        font-style: italic;
        color: #4EC2F7;
    }

    .footer {
        position: absolute;
        bottom: 0;
        width: 100%;
        height: 60px;
        line-height: 60px;
        background-color: #f5f5f5;
    }
    ```

1. Update the *application.properties* file at `src/main/resources/application.properties` with the following content:

    ```properties
    spring.application.name=quoteoftheday
    spring.datasource.url=jdbc:h2:mem:testdb
    spring.datasource.driverClassName=org.h2.Driver
    spring.datasource.username=sa
    spring.datasource.password=
    spring.jpa.database-platform=org.hibernate.dialect.H2Dialect
    spring.jpa.hibernate.ddl-auto=create-drop
    ```

## Use the variant feature flag

1. Open the *pom.xml* file and add the following dependencies for Azure App Configuration and feature management:

    ```xml
    <dependency>
        <groupId>com.azure.spring</groupId>
        <artifactId>spring-cloud-azure-starter-appconfiguration-config</artifactId>
    </dependency>

    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>com.azure.spring</groupId>
                <artifactId>spring-cloud-azure-dependencies</artifactId>
                <version>7.0.0</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>
    ```

1. Update the *application.properties* file at `src/main/resources/application.properties` to add Azure App Configuration settings:

    You can connect to your App Configuration store using Microsoft Entra ID (recommended), or a connection string.
    
    ### [Microsoft Entra ID (recommended)](#tab/entra-id)

    ```properties
    spring.config.import=azureAppConfiguration
    spring.cloud.azure.appconfiguration.stores[0].endpoint=${APP_CONFIGURATION_ENDPOINT}
    spring.cloud.azure.appconfiguration.stores[0].feature-flags.enabled=true
    ```

    You use the `DefaultAzureCredential` to authenticate to your App Configuration store. Follow the [instructions](./concept-enable-rbac.md#authentication-with-token-credentials) to assign your credential the **App Configuration Data Reader** role. Be sure to allow sufficient time for the permission to propagate before running your application.

    ### [Connection string](#tab/connection-string)

    ```properties
    spring.config.import=azureAppConfiguration
    spring.cloud.azure.appconfiguration.stores[0].connection-string=${APP_CONFIGURATION_CONNECTION_STRING}
    spring.cloud.azure.appconfiguration.stores[0].feature-flags.enabled=true
    ```

    ---

1. Create a new file named *MyTargetingContextAccessor.java* to provide the targeting context for the current user:

    ```java
    package com.example.quoteoftheday;

    import java.security.Principal;

    import org.springframework.stereotype.Component;
    import org.springframework.web.context.request.RequestContextHolder;
    import org.springframework.web.context.request.ServletRequestAttributes;

    import com.azure.spring.cloud.feature.management.targeting.TargetingContext;
    import com.azure.spring.cloud.feature.management.targeting.TargetingContextAccessor;

    @Component
    public class MyTargetingContextAccessor implements TargetingContextAccessor {

        @Override
        public void configureTargetingContext(TargetingContext context) {
            ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder
                    .getRequestAttributes();
            if (attributes != null) {
                Principal principal = attributes.getRequest().getUserPrincipal();
                if (principal != null) {
                    context.setUserId(principal.getName());
                }
            }
        }
    }
    ```

1. Update *HomeController.java* to use the variant feature flag:

    ```java
    package com.example.quoteoftheday;

    import java.security.Principal;
    import java.util.List;
    import java.util.Random;

    import org.slf4j.Logger;
    import org.slf4j.LoggerFactory;
    import org.springframework.stereotype.Controller;
    import org.springframework.ui.Model;
    import org.springframework.web.bind.annotation.GetMapping;

    import com.azure.spring.cloud.feature.management.FeatureManager;
    import com.azure.spring.cloud.feature.management.models.Variant;

    @Controller
    public class HomeController {

        private static final Logger LOGGER = LoggerFactory.getLogger(HomeController.class);

        private final FeatureManager featureManager;

        private final List<Quote> quotes = List.of(
                new Quote("You cannot change what you are, only what you do.", "Philip Pullman"));

        private final Random random = new Random();

        public HomeController(FeatureManager featureManager) {
            this.featureManager = featureManager;
        }

        @GetMapping("/")
        public String index(Model model, Principal principal) {
            String username = "Guest";
            if (principal != null) {
                username = principal.getName();
            }
            model.addAttribute("user", username);
            model.addAttribute("isAuthenticated", principal != null);

            // Get the variant for the Greeting feature flag
            String greetingMessage = "";
            Variant variant = featureManager.getVariant("Greeting");
            if (variant != null) {
                Object value = variant.getValue();
                if (value != null) {
                    greetingMessage = value.toString();
                }
            } else {
                LOGGER.warn(
                        "No variant given. Either the feature flag named 'Greeting' is not defined or the variants are not defined properly.");
            }

            model.addAttribute("greetingMessage", greetingMessage);
            model.addAttribute("quote", quotes.get(random.nextInt(quotes.size())));

            return "index";
        }
    }
    ```

## Build and run the app

1. Set an environment variable.

    ### [Microsoft Entra ID (recommended)](#tab/entra-id)

    Set the environment variable named **APP_CONFIGURATION_ENDPOINT** to the endpoint of your App Configuration store found under the *Overview* of your store in the Azure portal.

    If you use the Windows command prompt, run the following command and restart the command prompt to allow the change to take effect:

    ```cmd
    setx APP_CONFIGURATION_ENDPOINT "<endpoint-of-your-app-configuration-store>"
    ```

    If you use PowerShell, run the following command:

    ```powershell
    $Env:APP_CONFIGURATION_ENDPOINT = "<endpoint-of-your-app-configuration-store>"
    ```

    If you use macOS or Linux, run the following command:

    ```bash
    export APP_CONFIGURATION_ENDPOINT='<endpoint-of-your-app-configuration-store>'
    ```

    ### [Connection string](#tab/connection-string)

    Set the environment variable named **APP_CONFIGURATION_CONNECTION_STRING** to the read-only connection string of your App Configuration store found under *Access settings* of your store in the Azure portal.

    If you use the Windows command prompt, run the following command and restart the command prompt to allow the change to take effect:

    ```cmd
    setx APP_CONFIGURATION_CONNECTION_STRING "<connection-string-of-your-app-configuration-store>"
    ```

    If you use PowerShell, run the following command:

    ```powershell
    $Env:APP_CONFIGURATION_CONNECTION_STRING = "<connection-string-of-your-app-configuration-store>"
    ```

    If you use macOS or Linux, run the following command:

    ```bash
    export APP_CONFIGURATION_CONNECTION_STRING='<connection-string-of-your-app-configuration-store>'
    ```

    ---

1. Build and run your Spring Boot application with Maven:

    ```shell
    mvn clean package
    mvn spring-boot:run
    ```

1. Wait for the app to start, and then open a browser and navigate to `http://localhost:8080/`.

1. Once viewing the running application, select **Register** at the top right to register a new user.

    :::image type="content" source="media/use-variant-feature-flags-spring-boot/register.png" alt-text="Screenshot of the Quote of the day app, showing Register.":::

1. Register a new user named *usera@contoso.com*.

    > [!NOTE]
    > It's important for the purpose of this tutorial to use these names exactly. As long as the feature has been configured as expected, the two users should see different variants.

1. Select the **Submit** button after entering user information.

1. You're automatically logged in. You should see that usera@contoso.com sees the long message when viewing the app.

    :::image type="content" source="media/use-variant-feature-flags-spring-boot/special-message.png" alt-text="Screenshot of the Quote of the day app, showing a special message for the user.":::

1. Logout using the **Logout** button in the top right.

1. Register a second user named *userb@contoso.com*.

1. You're automatically logged in. You should see that userb@contoso.com sees the short message when viewing the app.

    :::image type="content" source="media/use-variant-feature-flags-spring-boot/message.png" alt-text="Screenshot of the Quote of the day app, showing a message for the user.":::

## Next steps

For the full feature rundown of the Spring Boot feature management library, refer to the following document.

> [!div class="nextstepaction"]
> [Use feature flags in a Spring Boot app](./use-feature-flags-spring-boot.md)
