import 'package:flutter/material.dart';

class TermsModal extends StatelessWidget {
  const TermsModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Terms and Conditions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context, false),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Last Updated: November 27, 2025',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  _SectionHeader('ARTICLE I. GENERAL ACCEPTANCE AND GOVERNING AGREEMENT'),
                  _SectionTitle('1.1 Acceptance of Terms'),
                  Text('By accessing, browsing, registering for an account, or otherwise utilizing the Done platform, including all associated websites, applications, and services (collectively, "the Platform"), you, the user ("User," "Client," or "Provider"), acknowledge that you have read, understood, and irrevocably agree to be bound by these Terms and Conditions ("Terms"), as well as our Privacy Policy, and any other policies or guidelines referenced herein. If you do not agree to the entirety of these Terms, you are explicitly prohibited from using the Platform and must cease use immediately.'),
                  
                  _SectionTitle('1.2 Modifications'),
                  Text('Done reserves the right, at its sole discretion, to modify or replace these Terms at any time. We will provide notice of material changes through the Platform or via email. By continuing to access or use the Platform after those revisions become effective, you agree to be bound by the revised Terms. The date of the last revision will be indicated at the top of this document.'),

                  _SectionTitle('1.3 Eligibility'),
                  Text('The Platform is intended solely for Users who are 18 years of age or older. Any access to or use of the Platform by anyone under 18 is expressly unauthorized and in violation of these Terms. By using the Platform, you represent and warrant that you are 18 years or older.'),

                  _SectionHeader('ARTICLE II. DESCRIPTION OF SERVICE AND PLATFORM ROLE'),
                  _SectionTitle('2.1 Service Definition'),
                  Text('The Platform operates as a neutral gig marketplace designed exclusively to facilitate the connection between Clients seeking specific, temporary services ("Jobs") and Providers offering professional services ("Gigs").'),

                  _SectionTitle('2.2 Platform as Facilitator'),
                  Text('Done is not an employer, agent, or representative of either Clients or Providers. Done\'s role is strictly limited to providing the technology infrastructure for posting, application, communication, and payment processing. Done does not supervise, direct, or control the work performed by Providers, nor does it guarantee the quality, suitability, or legality of the Jobs or Gigs offered. Users expressly acknowledge and agree that Done is not a party to any agreement or contract entered into between the Client and the Provider.'),

                  _SectionHeader('ARTICLE III. FINANCIAL TERMS AND FEES'),
                  _SectionTitle('3.1 Platform Transaction Fee'),
                  Text('Done shall charge a service fee ("Transaction Fee") equal to ten percent (10%) of the total agreed-upon monetary value for all completed transactions facilitated through the Platform. This fee is non-negotiable and is automatically calculated and deducted from the payment remitted to the Provider.'),

                  _SectionTitle('3.2 Payment Processing'),
                  Text('All payments for services rendered must be processed exclusively through the Platform\'s designated payment system. Any attempts to circumvent the Platform\'s payment system to avoid the Transaction Fee are a material breach of these Terms and will result in immediate account suspension and potential legal action.'),

                  _SectionTitle('3.3 Funding and Release'),
                  Text('Clients must pre-fund the full agreed-upon amount for a Job into an escrow or holding account before the Provider commences work. Funds will be held until the Client provides explicit approval of job completion. Providers will be paid upon Client approval, less the 10% Transaction Fee.'),

                  _SectionTitle('3.4 Non-Refundable Fees'),
                  Text('All Platform fees (the 10% Transaction Fee) are non-refundable, except in cases where Done determines, at its sole discretion, that the Provider failed to render any portion of the service whatsoever.'),

                  _SectionHeader('ARTICLE IV. USER ACCOUNTS AND RESPONSIBILITIES'),
                  _SectionTitle('4.1 Account Security'),
                  Text('Users are solely responsible for maintaining the confidentiality of their account credentials, including passwords. You agree to notify Done immediately of any unauthorized use of your account. Done will not be liable for any loss or damage arising from your failure to comply with this security obligation.'),

                  _SectionTitle('4.2 Client Representations and Warranties'),
                  Text('The Client represents and warrants that they shall:\n• Provide complete, accurate, and non-misleading descriptions of the Job requirements, scope, and expected outcomes.\n• Provide a safe, appropriate, and lawful working environment, if applicable.\n• Not require the Provider to perform any illegal, unethical, or dangerous activities.\n• Release payment promptly upon confirmation of satisfactory work completion.'),

                  _SectionTitle('4.3 Provider Representations and Warranties'),
                  Text('The Provider represents and warrants that they shall:\n• Possess the necessary skills, qualifications, licenses, and permits required to perform the services advertised.\n• Perform all services in a professional, timely, and workmanlike manner.\n• Bear sole responsibility for all federal, state, and local taxes, insurance, and other liabilities associated with their provision of services as an independent contractor.\n• Communicate any delays or issues that may affect the completion of the Job promptly to the Client.'),

                  _SectionHeader('ARTICLE V. PROHIBITED CONDUCT AND INTELLECTUAL PROPERTY'),
                  _SectionTitle('5.1 Prohibited Activities'),
                  Text('Users must not engage in, or attempt to engage in, the following prohibited activities:\n• Fee Circumvention: Contacting other Users identified through the Platform to solicit or offer services outside of the Platform.\n• Fraud: Posting or applying for Jobs with fraudulent, misleading, or illegal intent.\n• Harassment: Engaging in any form of verbal, physical, or digital harassment, discrimination, or abuse.\n• IP Infringement: Posting content that infringes on any third party\'s intellectual property rights.\n• Spam/Malware: Uploading or distributing any malicious code, viruses, or unsolicited commercial communications.'),

                  _SectionTitle('5.2 User Content License'),
                  Text('By posting, uploading, or displaying any content (including text, images, reviews, and portfolio items) on the Platform ("User Content"), you grant Done a non-exclusive, royalty-free, transferable, sub-licensable, worldwide license to use, modify, reproduce, distribute, and display such User Content in connection with the operation of the Platform and Done’s (and its successors\' and affiliates\') business.'),

                  _SectionTitle('5.3 Work Product'),
                  Text('Unless explicitly agreed upon otherwise in writing between the Client and Provider, the Provider agrees that any intellectual property rights arising from the work product created under a Job are automatically assigned to the Client upon final payment. Done claims no ownership rights over the intellectual property created between Users.'),

                  _SectionHeader('ARTICLE VI. INDEMNIFICATION AND WAIVER'),
                  _SectionTitle('6.1 User Indemnification'),
                  Text('You agree to indemnify, defend, and hold harmless Done, its affiliates, officers, directors, employees, and agents from and against any and all claims, liabilities, damages, losses, costs, and expenses, including reasonable attorneys\' fees, arising out of or in any way connected with:\n• Your access to or use of the Platform.\n• Your breach of these Terms or any representations and warranties contained herein.\n• Any claim that your User Content or the services you provided/received infringed the rights of a third party.\n• Any injury, damage, or harm caused by a Provider to a Client, or by a Client to a Provider, or to any third party property or person.'),

                  _SectionTitle('6.2 Waiver of Liability'),
                  Text('You acknowledge that the Platform operates as a third-party venue. To the maximum extent permitted by applicable law, you hereby waive, release, and forever discharge Done from any and all claims, demands, and damages (actual and consequential) of every kind and nature, known and unknown, suspected and unsuspected, disclosed and undisclosed, arising out of or in any way connected with any disputes between you and other Users.'),

                  _SectionHeader('ARTICLE VII. LIMITATION OF LIABILITY AND DISCLAIMER OF WARRANTIES'),
                  _SectionTitle('7.1 NO WARRANTY'),
                  Text('THE PLATFORM IS PROVIDED ON AN "AS IS" AND "AS AVAILABLE" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT. Done specifically disclaims any warranty that the Platform or any services obtained through the Platform will:\n• Meet your requirements.\n• Be available on an uninterrupted, secure, or error-free basis.\n• Be of a specific quality or standard.'),

                  _SectionTitle('7.2 LIMITATION OF LIABILITY'),
                  Text('TO THE MAXIMUM EXTENT PERMITTED BY LAW, IN NO EVENT SHALL DONE, ITS AFFILIATES, OFFICERS, OR DIRECTORS BE LIABLE FOR ANY INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES, INCLUDING, BUT NOT LIMITED TO, LOST PROFITS, LOST DATA, SERVICE INTERRUPTION, COMPUTER DAMAGE, OR SYSTEM FAILURE, OR THE COST OF SUBSTITUTE SERVICES, ARISING OUT OF OR IN CONNECTION WITH THESE TERMS OR FROM THE USE OF OR INABILITY TO USE THE PLATFORM, EVEN IF DONE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. Done\'s total cumulative liability for any and all claims arising out of or related to these Terms or your use of the Platform shall not exceed the greater of: (i) the amount of fees paid by you to Done in the twelve (12) months preceding the event giving rise to the liability, or (ii) One Hundred U.S. Dollars ($100.00).'),

                  _SectionHeader('ARTICLE VIII. DISPUTE RESOLUTION AND GOVERNING LAW'),
                  _SectionTitle('8.1 Mandatory Binding Arbitration'),
                  Text('Any controversy or claim arising out of or relating to these Terms, or the breach thereof, shall be settled by binding arbitration administered by the American Arbitration Association ("AAA") under its Commercial Arbitration Rules, and judgment on the award rendered by the arbitrator(s) may be entered in any court having jurisdiction thereof. The arbitration shall take place in the State of California.'),

                  _SectionTitle('8.2 Class Action Waiver'),
                  Text('You and Done agree that each may bring claims against the other only in your or its individual capacity, and not as a plaintiff or class member in any purported class or representative proceeding.'),

                  _SectionTitle('8.3 Governing Law'),
                  Text('These Terms shall be governed by and construed in accordance with the laws of the United States and the State of California, without regard to its conflict of law principles.'),

                  _SectionHeader('ARTICLE IX. TERM AND TERMINATION'),
                  _SectionTitle('9.1 Term'),
                  Text('These Terms shall remain in full force and effect while you use the Platform.'),

                  _SectionTitle('9.2 Termination by Done'),
                  Text('Done may suspend or terminate your account and access to the Platform at its sole discretion, immediately and without prior notice or liability, if you violate any provision of these Terms or for any other reason, including but not limited to inactivity.'),

                  _SectionTitle('9.3 Effect of Termination'),
                  Text('Upon any termination, all provisions of these Terms which by their nature should survive termination, including, without limitation, ownership provisions, warranty disclaimers, indemnity, and limitations of liability, shall remain in effect.'),

                  _SectionHeader('ARTICLE X. MISCELLANEOUS PROVISIONS'),
                  _SectionTitle('10.1 Severability'),
                  Text('If any provision of these Terms is held to be invalid or unenforceable, such provision shall be eliminated or limited to the minimum extent necessary, and the remaining provisions of these Terms will remain in full force and effect.'),

                  _SectionTitle('10.2 Entire Agreement'),
                  Text('These Terms, along with the Privacy Policy, constitute the entire and exclusive agreement between Done and you regarding the Platform, and these Terms supersede and replace any prior agreements.'),
                  
                  SizedBox(height: 20),
                  Text('Contact Information for Legal Inquiries:\nEmail: legal@done-app.com\nAddress: [Your Company Address]'),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('I Agree'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }
}
