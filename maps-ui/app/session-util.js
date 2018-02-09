module.exports.setSessionData = function (sessionData, data) {
  // Plan & create
  sessionData['promotername'] = data.promoterName
  sessionData['usrn'] = data.USRN
  sessionData['roadcategorygroup'] = data.roadCategoryGroup
  sessionData['highwayauthority'] = data.highwayAuthority
  sessionData['workreferencenumber'] = data.workReferenceNumber
  sessionData['start-day'] = data.startDay
  sessionData['start-month'] = data.startMonth
  sessionData['start-year'] = data.startYear
  sessionData['end-day'] = data.endDay
  sessionData['end-month'] = data.endMonth
  sessionData['end-year'] = data.endYear
  sessionData['duration'] = data.duration
  sessionData['trafficmanagementtypegroup'] = data.trafficManagementTypeGroup
  sessionData['workcategorygroup'] = data.workCategoryGroup
  sessionData['Screen1Complete'] = data.screen1Complete
  // Location & contact
  sessionData['works-location-description'] = data.worksLocationDescription
  sessionData['works-location-group'] = data.worksLocationGroup
  sessionData['description-of-work-group'] = data.descriptionOfWorkGroup
  sessionData['description-of-work-2'] = data.descriptionOfWork2
  sessionData['excavation-group'] = data.excavationGroup
  sessionData['contact-details'] = data.contactDetails
  sessionData['promoter-agent'] = data.promoterAgent
  sessionData['secondary-contact'] = data.secondaryContact
  sessionData['commercially-sensitive-group'] = data.commerciallySensitiveGroup
  sessionData['lane-rental-group'] = data.laneRentalGroup
  sessionData['Screen2Complete'] = data.screen2Complete
  // Conditions
  sessionData['conditions-name'] = data.conditionsName
  sessionData['conditions-reason'] = data.conditionsReason
  sessionData['Screen3Complete'] = data.screen3Complete
  // Collaboration
  sessionData['tm-group'] = data.tmGroup
  sessionData['file-attached-detail'] = data.fileAttachedDetail
  sessionData['file-attached-name'] = data.fileAttachedName
  sessionData['collaboration-group'] = data.collaborationGroup
  sessionData['collaboration-type-group'] = data.collaborationTypeGroup
  sessionData['collaboration-details'] = data.collaborationDetails
  sessionData['environmental-health-group'] = data.environmentalHealthGroup
  sessionData['project-reference'] = data.projectReference
  sessionData['Screen4Complete'] = data.screen4Complete
  // On Site
  sessionData['actual-start-date-day'] = data.actualStartDateDay
  sessionData['actual-start-date-month'] = data.actualStartDateMonth
  sessionData['actual-start-date-year'] = data.actualStartDateYear
  sessionData['actual-start-date-hour'] = data.actualStartDateHour
  sessionData['actual-start-date-minute'] = data.actualStartDateMinute
  sessionData['actual-end-date-day'] = data.actualEndDateDay
  sessionData['actual-end-date-month'] = data.actualEndDateMonth
  sessionData['actual-end-date-year'] = data.actualEndDateYear
  sessionData['actual-end-date-hour'] = data.actualEndDateHour
  sessionData['actual-end-date-minute'] = data.actualEndDateMinute
  sessionData['excavation-required-group'] = data.excavationRequiredGroup
  sessionData['Screen6Complete'] = data.screen6Complete
}
