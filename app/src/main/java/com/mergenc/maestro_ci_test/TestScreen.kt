package com.mergenc.maestro_ci_test

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.mergenc.maestro_ci_test.ui.theme.MaestrocitestTheme

@Composable
fun TestScreen(
    input: String,
    modifier: Modifier = Modifier,
    onBackToSecond: () -> Unit,
    onBackToFirst: () -> Unit
) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .padding(16.dp),
        verticalArrangement = Arrangement.Center
    ) {
        Text("Test ekrani")
        Text(
            text = "Kontrol metni: $input",
            modifier = Modifier.padding(top = 8.dp)
        )
        Button(
            modifier = Modifier
                .padding(top = 16.dp)
                .fillMaxWidth()
                .height(48.dp),
            onClick = onBackToSecond
        ) {
            Text("Ikinci ekrana don")
        }
        Button(
            modifier = Modifier
                .padding(top = 8.dp)
                .fillMaxWidth()
                .height(48.dp),
            onClick = onBackToFirst
        ) {
            Text("Ana ekrana don")
        }
    }
}

@Preview(showBackground = true)
@Composable
fun TestScreenPreview() {
    MaestrocitestTheme {
        TestScreen(
            input = "Deneme",
            onBackToSecond = {},
            onBackToFirst = {}
        )
    }
}
