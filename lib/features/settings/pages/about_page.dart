import 'package:flutter/material.dart';
import 'package:gestion_depenses/core/themes/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Future<void> _openGithub() async {
    final Uri url = Uri.parse('https://github.com/ItokianaIZ07');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      appBar: AppBar(
        title: const Text('À propos'),
        backgroundColor: AppTheme.colors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildHeaderCard(),

            _buildDeveloperCard(),

            _buildAboutCard(),

            _buildBackButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SpendWise',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppTheme.colors.primary,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Version v1.1',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.colors.secondary,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            "Une application simple et pratique pour gérer votre salaire, "
            "suivre vos dépenses, définir votre budget quotidien, gérer vos "
            "catégories et leurs limites mensuelles, et garder un meilleur "
            "contrôle de vos finances au quotidien.",
            style: TextStyle(
              fontSize: 14,
              height: 1.55,
              color: AppTheme.colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Développeur',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.colors.text,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.colors.primary, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.colors.shadow.withValues(alpha: 0.15),
                  offset: const Offset(0, 6),
                  blurRadius: 10,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset('assets/images/dev.jpg', fit: BoxFit.cover),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Étudiant en informatique, je conçois des applications '
            'mobiles et web avec passion.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: AppTheme.colors.textMuted,
            ),
          ),

          const SizedBox(height: 16),

          _buildInfoRow('GitHub', 'ItokianaIZ07', isLink: true),

          _buildInfoRow('Nom', 'RABARIVELONJATOVO ZELIARILALA'),

          _buildInfoRow('Prénom', 'Itokiana'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isLink = false}) {
    return InkWell(
      onTap: isLink ? _openGithub : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppTheme.colors.border, width: 1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.colors.textMuted,
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isLink
                      ? AppTheme.colors.primary
                      : AppTheme.colors.text,
                  decoration: isLink
                      ? TextDecoration.underline
                      : TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'À propos de l\'application',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.colors.text,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'SpendWise a été conçu pour aider à enregistrer '
            'rapidement les dépenses, visualiser les tendances mensuelles '
            'et mieux organiser ses finances personnelles.',
            style: TextStyle(
              fontSize: 14,
              height: 1.55,
              color: AppTheme.colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.colors.primary,
          foregroundColor: AppTheme.colors.surface,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radius.md),
          ),
          elevation: 2,
        ),
        child: const Text(
          'Retour',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppTheme.colors.surface,
      borderRadius: BorderRadius.circular(AppTheme.radius.lg),
      boxShadow: [
        BoxShadow(
          color: AppTheme.colors.shadow.withValues(alpha: 0.08),
          offset: const Offset(0, 2),
          blurRadius: 8,
        ),
      ],
    );
  }
}
