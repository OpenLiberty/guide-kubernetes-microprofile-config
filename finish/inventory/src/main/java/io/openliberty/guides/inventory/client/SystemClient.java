// tag::copyright[]
/*******************************************************************************
 * Copyright (c) 2017, 2024 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License 2.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-2.0/
 *
 * SPDX-License-Identifier: EPL-2.0
 *******************************************************************************/
// end::copyright[]
package io.openliberty.guides.inventory.client;

import java.net.URI;
import java.util.Base64;
import java.util.Properties;

import jakarta.enterprise.context.RequestScoped;
import jakarta.inject.Inject;
import jakarta.ws.rs.client.Client;
import jakarta.ws.rs.client.ClientBuilder;
import jakarta.ws.rs.client.Invocation.Builder;
import jakarta.ws.rs.core.HttpHeaders;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.core.Response.Status;

import org.eclipse.microprofile.config.inject.ConfigProperty;

@RequestScoped
public class SystemClient {

  // Constants for building URI to the system service.
  private final String SYSTEM_PROPERTIES = "/system/properties";
  private final String PROTOCOL = "http";

  // tag::context-root[]
  @Inject
  @ConfigProperty(name = "CONTEXT_ROOT", defaultValue = "")
  String CONTEXT_ROOT;
  // end::context-root[]

  @Inject
  @ConfigProperty(name = "http.port")
  String HTTP_PORT;

  // Basic Auth Credentials
  // tag::credentials[]
  // tag::system-app-username[]
  @Inject
  @ConfigProperty(name = "SYSTEM_APP_USERNAME")
  private String username;
  // end::system-app-username[]

  // tag::system-app-password[]
  @Inject
  @ConfigProperty(name = "SYSTEM_APP_PASSWORD")
  private String password;
  // end::system-app-password[]
  // end::credentials[]

  // Wrapper function that gets properties
  public Properties getProperties(String hostname) {
    Properties properties = null;
    Client client = ClientBuilder.newClient();
    try {
        Builder builder = getBuilder(hostname, client);
        properties = getPropertiesHelper(builder);
    } catch (Exception e) {
        System.err.println(
        "Exception thrown while getting properties: " + e.getMessage());
    } finally {
        client.close();
    }
    return properties;
  }

  // Method that creates the client builder
  private Builder getBuilder(String hostname, Client client) throws Exception {
    // tag::context-root1[]
    URI uri = new URI(
                  PROTOCOL, null, hostname, Integer.valueOf(HTTP_PORT),
                  CONTEXT_ROOT + SYSTEM_PROPERTIES, null, null);
    // end::context-root1[]
    String urlString = uri.toString();
    Builder builder = client.target(urlString).request();
    builder.header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON)
           .header(HttpHeaders.AUTHORIZATION, getAuthHeader());
    return builder;
  }

  // Helper method that processes the request
  private Properties getPropertiesHelper(Builder builder) throws Exception {
    Response response = builder.get();
    if (response.getStatus() == Status.OK.getStatusCode()) {
        return response.readEntity(Properties.class);
    } else {
        System.err.println("Response Status is not OK.");
        return null;
    }
  }

  private String getAuthHeader() {
    String usernamePassword = username + ":" + password;
    String encoded = Base64.getEncoder().encodeToString(usernamePassword.getBytes());
    return "Basic " + encoded;
  }
}
