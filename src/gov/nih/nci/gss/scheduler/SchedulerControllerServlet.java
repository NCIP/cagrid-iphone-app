/**
 * 
 */
package gov.nih.nci.gss.scheduler;

import gov.nih.nci.gss.util.Constants;
import gov.nih.nci.gss.util.HibernateUtil;
import gov.nih.nci.system.dao.orm.ORMDAOImpl;

import javax.servlet.ServletConfig;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;

import org.apache.log4j.Logger;
import org.quartz.JobDetail;
import org.quartz.Scheduler;
import org.quartz.SchedulerException;
import org.quartz.SimpleTrigger;
import org.quartz.Trigger;
import org.quartz.TriggerUtils;
import org.quartz.ee.servlet.QuartzInitializerServlet;
import org.quartz.impl.StdSchedulerFactory;
import org.springframework.web.context.WebApplicationContext;
import org.springframework.web.context.support.WebApplicationContextUtils;

/**
 * @author sahnih
 * 
 */
public class SchedulerControllerServlet extends HttpServlet {
	private static final String INTERVAL_IN_MINUTES = "intervalInMinutes";
	private static final long serialVersionUID = -1204015939687319924L;
	private static Logger logger = Logger
			.getLogger(SchedulerControllerServlet.class);
	// The Quartz Scheduler
	private static Scheduler scheduler = null;

	public void init() throws ServletException {
		ServletContext context = this.getServletContext();

		logger.info("Initializing SchedulerControllerServlet");
		
        WebApplicationContext ctx =  
            WebApplicationContextUtils.getWebApplicationContext(context);
        HibernateUtil.setSessionFactory(((ORMDAOImpl)ctx.getBean("ORMDAO")).getHibernateTemplate().getSessionFactory());

        // Retrieve the factory from the ServletContext.
		// It will be put there by the Quartz Servlet
		StdSchedulerFactory factory = (StdSchedulerFactory) context
				.getAttribute(QuartzInitializerServlet.QUARTZ_FACTORY_KEY);

		try {
			// Retrieve the scheduler from the factory
			scheduler = factory.getScheduler();
			if (scheduler != null) {
				scheduler.start();
				int intervalInMinutes = getIntervalInMinutes(this
						.getServletConfig());
				initialiseJob(intervalInMinutes);
			}
		} catch (SchedulerException e) {
			logger.error("Error setting up scheduler", e);
		}

	}

	private int getIntervalInMinutes(ServletConfig servletConfig) {
		Integer intervalInMinutes = 0;
		try {
			intervalInMinutes = new Integer(servletConfig
					.getInitParameter(INTERVAL_IN_MINUTES));
		} catch (NumberFormatException e) {
			// use default
			intervalInMinutes = Constants.DEFAULT_DISCOVERY_INTERVAL_IN_MINS;
		}
		return intervalInMinutes.intValue();

	}

	public void initialiseJob(int intervalInMinutes) {

		try {
			Trigger trigger = null;
			if (intervalInMinutes == 0) {
				intervalInMinutes = Constants.DEFAULT_DISCOVERY_INTERVAL_IN_MINS; // default
																					// is
																					// 720
																					// minutes
			}
			trigger = TriggerUtils.makeMinutelyTrigger(
					"GridDiscoveryServiceJobTrigger", intervalInMinutes,
					SimpleTrigger.REPEAT_INDEFINITELY);

			JobDetail jobDetail = new JobDetail("GridDiscoveryServiceJob",
					null, GridDiscoveryServiceJob.class);

			scheduler.scheduleJob(jobDetail, trigger);
			logger.debug("Discover Scheduler started, will run every " + Integer.toString(intervalInMinutes) + " minutes");

		} catch (SchedulerException e) {
			logger.error(e.getMessage(), e);
		}
	}

}
