// tag::copyright[]
/*******************************************************************************
* Copyright (c) 2022 IBM Corporation and others.
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*
* Contributors:
*     IBM Corporation - Initial implementation
*******************************************************************************/
// end::copyright[]
// tag::InventoryStartupCheck[]
 package io.openliberty.guides.inventory.health;

 import java.lang.management.ManagementFactory;
 import io.openliberty.guides.inventory.InventoryResource;

 import com.sun.management.OperatingSystemMXBean;

 import org.eclipse.microprofile.health.HealthCheck;
 import org.eclipse.microprofile.health.HealthCheckResponse;
 import org.eclipse.microprofile.health.Startup;

 import jakarta.enterprise.context.ApplicationScoped;

 // tag::Startup[]
 @Startup
 // end::Startup[]
 @ApplicationScoped
 public class InventoryStartupCheck implements HealthCheck {

     @Override
     public HealthCheckResponse call() {
         //OperatingSystemMXBean bean = (com.sun.management.OperatingSystemMXBean)
         //ManagementFactory.getOperatingSystemMXBean();
         //double cpuUsed = bean.getSystemCpuLoad();
         //String cpuUsage = String.valueOf(cpuUsed);
         //return HealthCheckResponse.named(InventoryResource.class
         //                                    .getSimpleName() + " Startup Check")
         //                                    .status(cpuUsed < 0.95).build();
         return HealthCheckResponse.up(STARTUP_CHECK);
     }
 }

 // end::InventoryStartupCheck[]