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
package io.openliberty.guides.system;

// CDI
import jakarta.enterprise.context.RequestScoped;
import jakarta.inject.Inject;
import jakarta.ws.rs.GET;
// JAX-RS
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

import org.eclipse.microprofile.config.inject.ConfigProperty;

@RequestScoped
@Path("/properties")
public class SystemResource {

  @Inject
  @ConfigProperty(name = "HOSTNAME")
  private String hostname;

  @GET
  @Produces(MediaType.APPLICATION_JSON)
  public Response getProperties() {
    return Response.ok(System.getProperties())
      .header("X-Pod-Name", hostname)
      .header("X-App-Name", "system")
      .build();
  }
}
