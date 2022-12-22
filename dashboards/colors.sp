/* Naming guidelines:
 * - Service categories taken from https://docs.aws.amazon.com/whitepapers/latest/aws-overview/amazon-web-services-cloud-platform.html
 * - Each variable should end with the word "color"
 * - If a service category includes the word "service(s)", exclude it
 * - If some words in the service category title are plural, keep them as plural, e.g., "Developer Tools" is "developer_tools_color"
 * - Do not shorten words, e.g., "Business Applications" is "business_applications_color"
 * - Do not include "and", e.g., "Management and Governance" is "management_governance_color"
 * - Break up service categories when they can stand on their own, e.g., "Security, Identity, and Compliance" has 3 standalone categories
 * - Use acronyms when well known and there's no room for ambiguity, e.g., "cd" could be continuous delivery or content delivery
*/

locals {
  developer_tools_color = "blue"
  iam_color             = "red"
}
